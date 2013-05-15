###My vim configuration.

I put all of this in $HOME/.vim.  I then make a link from $HOME/.vim/vimrc to $HOME/.vimrc

I'm using tpope's pathogen to handle plugins.
You can update the bundles by

```git submodule update --recursive```

Or if you haven't init a submodule

```git submodule foreach --recursive git pull origin master```


TIPS:
  "*p to paste from system copy buffer
  use ^P/^N in insert mode to complete words
  ^] to jump to tags
  ^W s,^W v - split windows
  gt/gT switching between tabs (or use mappings below)
  f<letter> / t<letter> - jump to next letter or before letter
  gv - highlight last visual
  gg=G - Indent the whole file

  <F5> - Toggle paste mode
  
