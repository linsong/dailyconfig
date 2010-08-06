" Vim plug-in
" Maintainer: Peter Odding <peter@peterodding.com>
" Last Change: July 12, 2010
" URL: http://peterodding.com/code/vim/profile/autoload/xolox/swapchoice.vim

function! xolox#swapchoice#change(augroup, value)
  let lines = []
  call add(lines, 'augroup ' . a:augroup)
  call add(lines, '  execute "autocmd SwapExists * let v:swapchoice = ' . string(a:value) . '"')
  call add(lines, 'augroup END')
  return join(lines, " | ")
endfunction

function! xolox#swapchoice#restore(augroup)
  let lines = []
  call add(lines, 'execute "autocmd! ' . a:augroup . '"')
  call add(lines, 'execute "augroup! ' . a:augroup . '"')
  return join(lines, " | ")
endfunction
