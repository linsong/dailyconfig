if ! exists("b:twitter_ini")
  let b:twitter_ini = 1

  highlight CursorLine term=reverse ctermbg=3
  setlocal cursorline

  map <buffer> <F5> :RefreshTwitter<CR>

  " navigate between stacks
  map <buffer> J :BackTwitter<CR>
  map <buffer> K :ForwardTwitter<CR>

  " navigate between pages
  map <buffer> > :NextTwitter<CR>
  map <buffer> < :PreviousTwitter<CR>
end
