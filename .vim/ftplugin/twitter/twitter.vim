if ! exists("b:twitter_ini")
  let b:twitter_ini = 1

  map <buffer> <F5> :RefreshTwitter<CR>
end
