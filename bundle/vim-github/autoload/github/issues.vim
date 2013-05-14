" Access to the Github Issues.
" Version: 0.1.0
" Author : thinca <thinca+vim@gmail.com>
" License: Creative Commons Attribution 2.1 Japan License
"          <http://creativecommons.org/licenses/by/2.1/jp/deed.en>

let s:save_cpo = &cpo
set cpo&vim


" Keep the issues.
let s:repos = {}


" Issues object  {{{1
let s:Issues = github#base()
let s:Issues.name = 'issues'

function! s:Issues.initialize(user, repos)
  let [self.user, self.repos] = [a:user, a:repos]
  let self.issues = []  " issues: Always sorted by issue number.
endfunction

function! s:Issues.get(number)
  return self.issues[a:number - 1]
endfunction

function! s:Issues.list()
  return copy(self.issues)
endfunction

function! s:Issues.comment_count(number)
  let comments = self.get(a:number).comments
  return type(comments) == type(0) ? comments : len(comments)
endfunction

function! s:Issues.update_list()
  let open = self.connect('list', 'open')
  let closed = self.connect('list', 'closed')

  let self.issues = sort(open.issues + closed.issues,
  \                      s:func('order_by_number'))
  call map(self.issues, 's:normalize_issue(v:val)')
endfunction

function! s:Issues.create_new_issue(title, body)
  let issue = self.connect('open', {'title': a:title, 'body': a:body}).issue
  call add(self.issues, s:normalize_issue(issue))
  return issue
endfunction

function! s:Issues.update_issue(number, title, body)
  let res = self.connect('edit', a:number, {'title': a:title, 'body': a:body})
  let res.issue.comments = self.issues[a:number - 1].comments
  let self.issues[a:number - 1] = res.issue
endfunction

function! s:Issues.add_comment(number, comment)
  let comment = self.connect('comment', a:number, {'comment': a:comment})
  call add(self.get(a:number).comments, comment.comment)
endfunction

function! s:Issues.fetch_comments(number, ...)
  let issue = self.get(a:number)
  let force = a:0 && a:1
  if force || type(issue.comments) == type(0)
    let issue.comments = self.connect('comments', issue.number).comments
  endif
endfunction

function! s:Issues.add_labels(label, number)
  return self.update_labels(a:label, a:number, 'add')
endfunction

function! s:Issues.remove_labels(label, number)
  return self.update_labels(a:label, a:number, 'remove')
endfunction

function! s:Issues.update_labels(label, number, ...)
  " op = 'add'/'remove'/'all'
  let op = a:0 ? a:1 : 'all'
  if op ==# 'all'
    let current_labels = self.get(a:number).labels
    let adds = s:list_sub(a:label, current_labels)
    let removes = s:list_sub(current_labels, a:label)
    call self.add_labels(adds, a:number)
    call self.remove_labels(removes, a:number)
  else
    for l in type(a:label) == type([]) ? a:label : [a:label]
      let args = ['label/' . op, a:label] + (a:number != 0 ? [a:number] : [])
      let new_labels = call(self.connect, args, self)
    endfor
    if a:number != 0 && exists('new_labels')
      let target = self.get(a:number)
      let target.labels = new_labels.labels
    endif
  endif
endfunction

function! s:Issues.close(number)
  let self.issues[a:number - 1] = self.connect('close', a:number).issue
endfunction

function! s:Issues.reopen(number)
  let self.issues[a:number - 1] = self.connect('reopen', a:number).issue
endfunction

function! s:Issues.connect(action, ...)
  let res = github#connect('/issues', a:action, self.user, self.repos,
  \      map(copy(a:000), 'type(v:val) == type(0) ? v:val . "" : v:val'))
  if has_key(res, 'error')
    throw 'github: issues: API error: ' . res.error
  endif
  return res
endfunction

function! s:normalize_issue(issue)
  if a:issue.comments is 0
    let a:issue.comments = []
  endif
  return a:issue
endfunction


" UI object  {{{1
let s:UI = {'name': 'issues'}

function! s:UI.initialize(issues)
  let self.issues = a:issues
  call self.update_issue_list()
endfunction

function! s:UI.update_issue_list()
  " Save the sorted list
  let list = sort(self.issues.list(), s:func('compare_list'))
  let self.issue_list = list
  let length = len(self.issue_list)
  let self.rev_index = range(length)
  for i in range(length)
    let self.rev_index[list[i].number - 1] = i
  endfor
endfunction

function! s:UI.opened(type)
  nnoremap <buffer> <silent> <Plug>(github-issues-action)
  \        :<C-u>call b:github_issues.action()<CR>

  silent! nmap <buffer> <unique> <CR> <Plug>(github-issues-action)

  if a:type ==# 'view'
    nnoremap <buffer> <silent> <Plug>(github-issues-issue-list)
    \        :<C-u>call b:github_issues.view('issue_list')<CR>
    nnoremap <buffer> <silent> <Plug>(github-issues-redraw)
    \        :<C-u>call b:github_issues.redraw()<CR>
    nnoremap <buffer> <silent> <Plug>(github-issues-reload)
    \        :<C-u>call b:github_issues.reload()<CR>
    nnoremap <buffer> <silent> <Plug>(github-issues-next)
    \        :<C-u>call b:github_issues.move(v:count1)<CR>
    nnoremap <buffer> <silent> <Plug>(github-issues-prev)
    \        :<C-u>call b:github_issues.move(-v:count1)<CR>

    nmap <buffer> <BS> <Plug>(github-issues-issue-list)
    nmap <buffer> <C-t> <Plug>(github-issues-issue-list)
    nmap <buffer> r <Plug>(github-issues-redraw)
    nmap <buffer> R <Plug>(github-issues-reload)
    nmap <buffer> <C-r> <Plug>(github-issues-reload)
    nmap <buffer> <C-j> <Plug>(github-issues-next)
    nmap <buffer> <C-k> <Plug>(github-issues-prev)

    augroup plugin-github-issues
      autocmd! * <buffer>
      autocmd BufEnter <buffer> call b:github_issues.redraw()
    augroup END
  endif
endfunction

function! s:UI.updated(type, name)
  if a:type ==# 'view'
    if a:name ==# 'issue_list'
      if has_key(self, 'issue')
        call search('^\s*' . self.issue.number . ':', 'w')
        call remove(self, 'issue')
      endif
    endif
  endif
endfunction

function! s:UI.header()
  return printf('Github Issues - %s/%s', self.issues.user, self.issues.repos)
endfunction

function! s:UI.view_issue_list()
  return ['[[new issue]]'] +
  \ map(copy(self.issue_list), 'self.line_format(v:val)')
endfunction

function! s:UI.view_issue(number)
  call self.issues.fetch_comments(a:number)

  let self.issue = self.issues.get(a:number)

  return ['[[edit]] ' . (self.issue.state ==# 'open' ?
  \       '[[close]]' : '[[reopen]]')] + self.issue_layout(self.issue)
endfunction

function! s:UI.edit_issue(...)
  let [title, labels, body] = a:0 ?
  \ [a:1.title, a:1.labels, a:1.body] :
  \ ['', [], "\n"]
  let text = ['[[POST]]']
  if a:0
    let text += ['number: ' . a:1.number]
  endif
  let text += ['title: ' . title]
  call add(text, 'labels: ' . join(labels, ', '))
  return text + ['body:'] + split(body, '\r\?\n', 1)
endfunction

function! s:UI.edit_comment(num)
  return ['[[POST]]', 'number: ' . a:num, 'comment:', '', '']
endfunction

function! s:UI.line_format(issue)
  return printf('%3d: %-6s| %s%s', a:issue.number, a:issue.state,
  \      join(map(copy(a:issue.labels), '"[".v:val."]"'), ''),
  \      substitute(a:issue.title, '\n', '', 'g'))
endfunction

function! s:UI.issue_layout(issue)
  let i = a:issue
  let lines = [
  \ i.number . ': ' . i.title,
  \ 'state: ' . i.state,
  \ 'user: ' . i.user,
  \ 'labels: ' . join(i.labels, ', '),
  \ 'created: ' . i.created_at,
  \ ]

  if i.created_at !=# i.updated_at
    let lines += ['updated: ' . i.updated_at]
  endif
  if has_key(i, 'closed_at') && i.closed_at != 0
    let lines += ['closed: ' . i.closed_at]
  endif
  if i.votes != 0
    let lines += ['votes: ' . i.votes]
  endif

  let lines += [''] + split(i.body, '\r\?\n') + ['', '']

  for c in i.comments
    let lines += [
    \ '------------------------------------------------------------',
    \ '  ' . c.user . ' ' . c.created_at,
    \ '',
    \ ]
    let lines += map(split(c.body, '\r\?\n'), '"  " . v:val')
  endfor

  let lines += ['', '', '[[add comment]]']

  return lines
endfunction


" Control.  {{{1
function! s:UI.action()
  try
    call self.perform(github#get_text_on_cursor('\[\[.\{-}\]\]'))
  catch /^github:/
    echohl ErrorMsg
    echomsg v:exception
    echohl None
  endtry
endfunction

function! s:UI.perform(button)
  let button = a:button
  if b:github_issues_buf ==# 'view_issue_list'
    if button ==# '[[new issue]]'
      call self.edit('issue')
    else
      let number = matchstr(getline('.'), '^\s*\zs\d\+\ze\s*:')
      if number =~ '^\d\+$'
        call self.view('issue', number)
      endif
    endif
  elseif b:github_issues_buf ==# 'view_issue'
    if button ==# '[[edit]]'
      call self.edit('issue', self.issue)
    elseif button ==# '[[close]]'
      let num = self.issue.number
      call self.issues.close(num)
      call self.view('issue', num)
    elseif button ==# '[[reopen]]'
      let num = self.issue.number
      call self.issues.reopen(num)
      call self.view('issue', num)
    elseif button ==# '[[add comment]]'
      call self.edit('comment', self.issue.number)
    endif
  elseif b:github_issues_buf ==# 'edit_issue'
    if button ==# '[[POST]]'
      let c = getpos('.')
      try
        1
        let bodystart = search('^\cbody:', 'n')
        if !bodystart
          throw 'github: issues: No body.'
        endif
        let body = join(getline(bodystart + 1, '$'), "\n")

        let titleline = search('^\ctitle:', 'Wn', bodystart)
        if !titleline
          throw 'github: issues: No title.'
        endif
        let title = matchstr(getline(titleline), '^\w\+:\s*\zs.\{-}\ze\s*$')
        if title == ''
          throw 'github: issues: Title is empty.'
        endif

        let labelsline = search('^\clabels:', 'Wn', bodystart)
        if labelsline
          let labels = filter(split(matchstr(getline(labelsline),
          \                   '^\w\+:\s*\zs.\{-}\ze\s*$'), '\s*,\s*'),
          \                   'v:val !~ "^\\s*$"')
        endif

        let numberline = search('^\cnumber:', 'Wn', bodystart)
        if numberline
          let number = matchstr(getline(numberline),
          \                     '^\w\+:\s*\zs.\{-}\ze\s*$')
          call self.issues.update_issue(number, title, body)

        else
          let issue = self.issues.create_new_issue(title, body)
          let number = issue.number
        endif

        if exists('labels')
          call self.issues.update_labels(labels, number)
        endif

      finally
        call setpos('.', c)
      endtry
    endif
  elseif b:github_issues_buf ==# 'edit_comment'
    if button ==# '[[POST]]'
      let c = getpos('.')
      try
        1
        let commentstart = search('^\ccomment:', 'n')
        if !commentstart
          throw 'github: issues: No comment.'
        endif
        let comment = join(getline(commentstart + 1, '$'), "\n")

        let numberline = search('^\cnumber:', 'Wn', commentstart)
        let number = matchstr(getline(numberline), '^\w\+:\s*\zs.\{-}\ze\s*$')
        call self.issues.add_comment(number, comment)

      finally
        call setpos('.', c)
      endtry
    endif
  endif

  call self.update_issue_list()

  if b:github_issues_buf =~# '^edit_' && button ==# '[[POST]]'
    close
  endif
endfunction

function! s:UI.redraw()
  if b:github_issues_buf ==# 'view_issue_list'
    call self.view('issue_list')
  elseif b:github_issues_buf ==# 'view_issue'
    call self.view('issue', self.issue.number)
  endif
endfunction

function! s:UI.reload()
  if b:github_issues_buf ==# 'view_issue_list'
    call self.issues.update_list()
    call self.update_issue_list()
    call self.view('issue_list')
  elseif b:github_issues_buf ==# 'view_issue'
    let self.issue.comments = 0
    call self.view('issue', self.issue.number)
  endif
endfunction

function! s:UI.move(cnt)
  let idx = (has_key(self, 'issue') ? self.rev_index[self.issue.number - 1]
  \                                 : -1) + a:cnt
  let length = len(self.issue_list)
  if idx == -2  " <C-k> in issue list.
    let idx = length - 1
  endif
  if idx < 0 || length <= idx
    call self.view('issue_list')
  else
    call self.view('issue', self.issue_list[idx].number)
  endif
endfunction

function! s:UI.invoke(args)
  if empty(a:args)
    throw 'github: issues: Require the repository name.'
  endif
  let repos = a:args[0]
  let [user, repos] = repos =~ '/' ? split(repos, '/')[0 : 1]
  \                                    : [g:github#user, repos]

  let key = user . '/' . repos
  if has_key(s:repos, key)
    let issues = s:repos[key]
  else
    let issues = s:Issues.new(user, repos)
    call issues.update_list()
    let s:repos[key] = issues
  endif
  let ui = self.new(issues)

  if len(a:args) == 1
    call ui.view('issue_list')
  else
    let id = a:args[1]
    if id =~ '^\d\+$'
      call ui.view('issue', id)
    elseif id ==# 'new'
      call ui.edit('issue')
    endif
  endif
endfunction


" Misc.  {{{1
function! s:order_by_number(a, b)
  return a:a.number - a:b.number
endfunction

function! s:compare_list(a, b)
  " TODO: Be made customizable.
  if a:a.state !=# a:b.state
    return a:a.state ==# 'open' ? -1 : 1
  endif
  return a:a.number - a:b.number
endfunction

function! s:list_sub(a, b)
  " Difference of list (a - b)
  let a = copy(a:a)
  call map(reverse(sort(filter(map(copy(a:b), 'index(a, v:val)'),
  \                            '0 <= v:val'))), 'remove(a, v:val)')
  return a
endfunction

function! s:func(name)
  return function(matchstr(expand('<sfile>'), '<SNR>\d\+_\zefunc$') . a:name)
endfunction

function! github#issues#new()
  return copy(s:UI)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo