" TIPS:
"   "*p to paste from system copy buffer
"   use ^P/^N in insert mode to complete words
"   ^] to jump to tags
"   ^W s,^W v - split windows
"   gt/gT switching between tabs (or use mappings below)
"   f<letter> / t<letter> - jump to next letter or before letter
"   gv - highlight last visual
"   gg=G - Indent the whole file
"   gc - comment
"   ^c^c - slime
"

"set guifont=Droid\ Sans\ Mono\ for\ Powerline\ Plus\ Nerd\ File\ Types\ 11
"set guifont=DroidSansMonoforPowerlinePlusNerdFileTypes
"set guifont=Droid\ Sans\ Mono\ for\ Powerline\ Plus\ Nerd\ File\ Types\ Regular\ 11
"set guifont=Droid\ Sans\ Mono\ for\ Powerline\ Plus\ Nerd\ File\ Types\ 11
set term=xterm-256color
set encoding=utf-8
set guifont=Droid\ Sans\ Mono\ for\ Powerline\ Regular

" first the disabled features due to security concerns
set modelines=0               " no modelines [http://www.guninski.com/vim1.html]
let g:secure_modelines_verbose=0 " securemodelines vimscript
let g:secure_modelines_modelines = 15 " 15 available modelines

execute pathogen#infect()

"call pathogen#runtime_append_all_bundles()
"silent! call pathogen#infect("~/.vim/depot")

set nocompatible
syntax on
set history=200   " keep 50 lines of command line history
set ruler   " show the cursor position all the time
set showcmd   " display incomplete commands
set incsearch   " do incremental searching
"set nu " line numbers
set backspace=indent,eol,start
set noerrorbells
set visualbell t_vb=          " Disable ALL bells

" xterm title
set title

set viminfo^=!

" support separate .vimrc for different projects
set exrc

au BufWritePost .vimrc so $MYVIMRC

let mapleader = ","

" tap leader twice and bring back to the last buffer I was on
nnoremap <leader><leader> :b#<cr>

" load .vimrc file quickly
nnoremap <leader>V :e $MYVIMRC<cr>

" alt+n or alt+p to navigate between entries in QuickFix
map <silent> <m-p> :cp <cr>
map <silent> <m-n> :cn <cr>

" Local configuration
" set runtimepath=~/.vim,/etc/vim,/usr/share/vim/vimfiles
" set runtimepath+=/usr/share/vim/addons,/usr/share/vim/vim61
" set runtimepath+=/usr/share/vim/vimfiles/after,~/.vim/after

" set runtimepath^=~/.vim/bundle/ctrlp.vim

" convert tabs to spaces. indent level is 2
set ts=2
set sw=2
set et

set showfulltag               " show full completion tags
"set wildignore+=*.o,*~,.lo    " ignore object files
"set wildmode=longest:full
"set wildmenu                  " menu has tab completion
"set complete=.,w,b,u,U,t,i,d  " do lots of scanning on tab completion

"set ttyfast

"set dictionary=/usr/share/dict/words

if has("vms")
  set nobackup    " do not keep a backup file, use versions instead
else
  set backup    " keep a backup file
  set backupdir=~/.vim/backup
  "set backupdir=./.backup,.,~/.vim/backup
  "set directory=.,./.backup,~/.vim/backup
endif

" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  set hlsearch
endif

"if !has("gui_running")
"     colorscheme default
if has("gui_running")
  set cursorline
  set background=light
  " ir_black looks great in macvim.  very close to textmate ir_black
  " if has("mac") could be used
  "set noantialias
  set guioptions-=T        " no toolbar
  colorscheme pyte
  "colorscheme ir_black
  "colorscheme macvim      " macvim == win
  map <MouseMiddle> <esc>"*p " paste with middle button
  set nu " it always looks fine in macvim
  set lines=40
  set columns=140
  "set gfn=Monaco:h9
else
  set background=light
"  colorscheme vividchalk
  let base16colorspace=256  " Access colors present in 256 colorspace
  colorscheme Monokai
  "colorscheme base16-tomorrow
  "colorscheme jellybeans
  "colorscheme liquidcarbon
  "colorscheme twilight
end

" If I forgot to sudo vim a file, do that with :w!!
cmap w!! %!sudo tee > /dev/null %

"noremap <F5> :w<CR>
"imap <F5> <ESC>:w<CR>

noremap <D-r> :!ruby %<CR>
map <leader>r :!ruby %<CR>

"Buffer next,previous (ctrl-{n,p})
noremap  :bn<CR>
noremap  :bp<CR>

nnoremap <F5> :set invpaste paste?<CR>
"imap <F5> <C-O>:set invpaste paste?<CR>
set pastetoggle=<F5>
set showmode

"netrw stuff
" http://mysite.verizon.net/astronaut/vim/index.html#NETRW
"
let g:netrw_altv          = 1
let g:netrw_fastbrowse    = 2
let g:netrw_keepdir       = 0
let g:netrw_liststyle     = 2
let g:netrw_retmap        = 1
let g:netrw_silent        = 1
let g:netrw_special_syntax= 1

" Don't use Ex mode, use Q for formatting
map Q gq

let maplocalleader = ","

" Make ',e' (in normal mode) give a prompt for opening files
" " in the same dir as the current buffer's file.
if has("unix")
  map <LocalLeader>e :e <C-R>=expand("%:p:h") . "/" <CR>
else
  map <LocalLeader>e :e <C-R>=expand("%:p:h") . "\\" <CR>
endif

"source ~/.vim/vim7.vim

" ---------------------------------------------------------------------------
" tabs
" (LocalLeader is ",")
map <LocalLeader>tc :tabnew<cr>    " create a new tab
map <LocalLeader>tC :tabnew %<cr>    " create a new tab
"map <LocalLeader>td :tabclose<cr>    " close a tab
map <LocalLeader>tq :tabclose<cr>    " close a tab
map <LocalLeader>tn :tabnext<cr>     " next tab
map <LocalLeader>tp :tabprev<cr>     " previous tab
map <LocalLeader>tm :tabmove         " move a tab to a new location


if has('mouse')
  set mouse=a
endif


" fuzzy finder textmate
if has("ruby")
  map <leader>f :FuzzyFinderTextMate<CR>

  " Autocomplete
  autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
  autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
  autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
  autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
  "improve autocomplete menu color
  highlight Pmenu ctermbg=238 gui=bold
else
  map <leader>f :FuzzyFinderFile<CR>
end

" BufExplorer
map <LocalLeader>bb :BufExplorer<CR>

" ---------------------------------------------------------------------------
"  configuration for fuzzyfinder
" find in buffer is ,fb
nmap <LocalLeader>fb :FuzzyFinderBuffer<CR>
" find in file is ,ff
nmap <LocalLeader>ff :FuzzyFinderFile<CR>
" find in tag is ,ft
nmap <LocalLeader>ft :FuzzyFinderTag<CR>

" ---------------------------------------------------------------------------
" Settings for gist.vim
if has("mac")
  let g:gist_clip_command = 'pbcopy'
end
let g:gist_detect_filetype = 1

" ---------------------------------------------------------------------------
" Settings for taglist.vim
let Tlist_Use_Right_Window=1
let Tlist_Auto_Open=0
let Tlist_Enable_Fold_Column=0
let Tlist_Compact_Format=0
let Tlist_WinWidth=28
let Tlist_Exit_OnlyWindow=1
let Tlist_File_Fold_Auto_Close = 1

if version >= 700

let NERDTreeIgnore=['\~$', '^\.git', '\.swp$', '\.DS_Store$']
let NERDTreeShowHidden=1

" ,tt will toggle taglist on and off
nmap <LocalLeader>tt :Tlist<cr>
" ,nn will toggle NERDTree on and off
nmap <LocalLeader>nn :NERDTreeToggle<cr>
map <leader>n :NERDTreeToggle<cr>

end

compiler ruby
"compiler python

set laststatus=2

"if has('statusline')
"        " Status line detail: (from Rafael Garcia-Suarez)
"        " %f    file path
"        " %y    file type between braces (if defined)
"        " %([%R%M]%)  read-only, modified and modifiable flags between braces
"        " %{'!'[&ff=='default_file_format']}
"        "     shows a '!' if the file format is not the platform
"        "     default
"        " %{'$'[!&list]}  shows a '*' if in list mode
"        " %{'~'[&pm=='']} shows a '~' if in patchmode
"        " (%{synIDattr(synID(line('.'),col('.'),0),'name')})
"        "     only for debug : display the current syntax item name
"        " %=    right-align following items
"        " #%n   buffer number
"        " %l/%L,%c%V  line number, total number of lines, and column number
"        "function! SetStatusLineStyle()
"        "        if &stl == '' || &stl =~ 'synID'
"        "                let &stl="%f %y%([%R%M]%)%{'!'[&ff=='".&ff."']}%{'$'[!&list]}" .
"        "                                        \"%{'~'[&pm=='']}"                     .
"        "                                        \"%=#%n %l/%L,%c%V "                   .
"        "                                        \"git:%{call GitBranch()}"
"        "        else
"        "                let &stl="%f %y%([%R%M]%)%{'!'[&ff=='".&ff."']}%{'$'[!&list]}" .
"        "                                        \" (%{synIDattr(synID(line('.'),col('.'),0),'name')})" .
"        "                                        \"%=#%n %l/%L,%c%V "
"        "        endif
"        "endfunc
"        "call SetStatusLineStyle()
"
"        if has("ruby")
"          let g:git_branch_status_head_current=1
"          let g:git_branch_status_ignore_remotes=1
"          let g:git_branch_status_text=""
"
"          function! SetStatusLineStyle()
"                  let &stl="%f %y "                       .
"                          \"%([%R%M]%)"                   .
"                          \"%#StatusLineNC#%{&ff=='unix'?'':&ff.'\ format'}%*" .
"                          \"%{'$'[!&list]}"               .
"                          \"%{'~'[&pm=='']}"              .
"                          \"%="                           .
"                          \"#%n %l/%L,%c%V "              .
"                          \"git:%{GitBranchInfoString()} "
"                          "\"%{rvm#statusline()} " .
"  "      \"%#StatusLineNC#%{GitBranchInfoString()}%* " .
"          endfunc
"        else
"          function! SetStatusLineStyle()
"                  let &stl="%f %y "                       .
"                          \"%([%R%M]%)"                   .
"                          \"%#StatusLineNC#%{&ff=='unix'?'':&ff.'\ format'}%*" .
"                          \"%{'$'[!&list]}"               .
"                          \"%{'~'[&pm=='']}"              .
"                          \"%="                           .
"                          \"#%n %l/%L,%c%V "
"          endfunc
"        end
"        call SetStatusLineStyle()
"
"        if has('title')
"                set titlestring=%t%(\ [%R%M]%)
"        endif
"
"        "highlight StatusLine    ctermfg=White ctermbg=DarkBlue cterm=bold
"        "highlight StatusLineNC  ctermfg=White ctermbg=DarkBlue cterm=NONE
"endif

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")


" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp
"

filetype on           " Enable filetype detection
filetype indent on    " Enable filetype-specific indenting
filetype plugin on    " Enable filetype-specific plugins


" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 80 characters.
  autocmd FileType text setlocal textwidth=80

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  augroup END

else
  set autoindent    " always set autoindenting on
endif " has("autocmd")

" Don't write backup file for some files
"au BufWrite /private/tmp/crontab.* set nowritebackup
"au BufWrite /private/tmp/crontab.* set nobackup
"au BufWrite /tmp/crontab.* set nowritebackup
"au BufWrite /tmp/crontab.* set nobackup
"au BufWrite /dev/shm/taylortmp/* set nowritebackup
"au BufWrite /dev/shm/taylortmp/* set nobackup

" We don't want a swap file and backup for these "private" files
"autocmd BufReadPre,FileReadPre ~/.mutt/private/* set viminfo=
"autocmd BufReadPre,FileReadPre ~/.mutt/private/* set noswapfile
"autocmd BufReadPre,FileReadPre ~/.mutt/private/* set nowritebackup

"autocmd BufReadPre,FileReadPre,BufWrite ~/.vim/tracserverlist set noswapfile
"autocmd BufReadPre,FileReadPre,BufWrite ~/.vim/tracserverlist set nobackup
"autocmd BufReadPre,FileReadPre,BufWrite ~/.vim/tracserverlist set nowritebackup

" au BufWrite /Users/taylor/sw/etc/pass set nowritebackup
" au BufWrite /Users/taylor/sw/etc/pass set nobackup
" au BufWrite /Users/taylor/sw/etc/pass set noswapfile

" au BufWrite pass set nowritebackup
" au BufWrite pass set nobackup
" au BufWrite pass set noswapfile

" au BufWrite ~/work/catalis/*pass* set nowritebackup
" au BufWrite ~/work/catalis/*pass* set nobackup
" au BufWrite ~/work/catalis/*pass* set noswapfile

autocmd BufReadPre,FileReadPre,BufWrite *credentials*,*authinfo*,.authinfo*,*pass,pass,pass.* set noswapfile
autocmd BufReadPre,FileReadPre,BufWrite *credentials*,*authinfo*,.authinfo*,*pass,pass,pass.* set nobackup
autocmd BufReadPre,FileReadPre,BufWrite *credentials*,*authinfo*,.authinfo*,*pass,pass,pass.* set nowritebackup

" set up syntax highlighting for my e-mail
au BufRead,BufNewFile .followup,.article,.letter,/tmp/pico*,nn.*,snd.*,/tmp/mutt*,sup.* :set ft=mail


" Transparent editing of gpg encrypted files.
" Placed Public Domain by Wouter Hanegraaff
" (asc support and sh -c"..." added by Osamu Aoki)
augroup aencrypted
  au!

  " First make sure nothing is written to ~/.viminfo while editing
  " an encrypted file.
  autocmd BufReadPre,FileReadPre *.asc set viminfo=
  " We don't want a various options which write unencrypted data to disk
  autocmd BufReadPre,FileReadPre *.asc set noswapfile noundofile nobackup

  " Switch to bin mode to read the encrypted file
  autocmd BufReadPre,FileReadPre *.asc set bin
  autocmd BufReadPre,FileReadPre *.asc let ch_save = &ch|set ch=2
  " (If you use tcsh, you may need to alter this line.)
  autocmd BufReadPost,FileReadPost *.asc '[,']!gpg --decrypt 2> /dev/null

  " Switch to normal mode for editing
  autocmd BufReadPost,FileReadPost *.asc set nobin
  autocmd BufReadPost,FileReadPost *.asc let &ch = ch_save|unlet ch_save
  autocmd BufReadPost,FileReadPost *.asc execute ":doautocmd BufReadPost " . expand("%:r")

  " Convert all text to encrypted text before writing
  " (If you use tcsh, you may need to alter this line.)
  autocmd BufWritePre,FileWritePre *.asc '[,']!gpg --default-recipient-self -ae 2>/dev/null
  " Undo the encryption so we are back in the normal text, directly
  " after the file has been written.
  autocmd BufWritePost,FileWritePost *.asc u
augroup END
augroup bencrypted
  au!

  " First make sure nothing is written to ~/.viminfo while editing
  " an encrypted file.
  autocmd BufReadPre,FileReadPre *.gpg set viminfo=
  " We don't want a various options which write unencrypted data to disk
  autocmd BufReadPre,FileReadPre *.gpg set noswapfile noundofile nobackup

  " Switch to binary mode to read the encrypted file
  autocmd BufReadPre,FileReadPre *.gpg set bin
  autocmd BufReadPre,FileReadPre *.gpg let ch_save = &ch|set ch=2
  " (If you use tcsh, you may need to alter this line.)
  autocmd BufReadPost,FileReadPost *.gpg '[,']!gpg --decrypt 2> /dev/null

  " Switch to normal mode for editing
  autocmd BufReadPost,FileReadPost *.gpg set nobin
  autocmd BufReadPost,FileReadPost *.gpg let &ch = ch_save|unlet ch_save
  autocmd BufReadPost,FileReadPost *.gpg execute ":doautocmd BufReadPost " . expand("%:r")

  " Convert all text to encrypted text before writing
  " (If you use tcsh, you may need to alter this line.)
  autocmd BufWritePre,FileWritePre *.gpg '[,']!gpg --default-recipient-self -ae 2>/dev/null
  " Undo the encryption so we are back in the normal text, directly
  " after the file has been written.
  autocmd BufWritePost,FileWritePost *.gpg u
augroup END

source ~/.vim/custom/settings.vim


