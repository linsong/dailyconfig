if ! exists("b:twitter_ini")
  let b:twitter_ini = 1

  highlight CursorLine term=reverse ctermbg=3
  setlocal cursorline

  map <buffer> <F5> :RefreshTwitter<CR>
end
