" Vim ftplugin file
" Language:	GTD (pyGTD)
" Version:      1.1
" Maintainer:	Michael M. Tung <mtung@mat.upv.es>
" Last Change:  Thu Nov 02 12:23:38 CET 2006

" A fast syntax hack for pyGTD todo and context files by Keith Martin.
" Check the webpage http://96db.com/pyGTD/ for the program and documentation.
" This plugin file is still in development. Please send suggestions
" to the maintainer.

" Prevent duplicate loading.
if exists("loaded_gtd")
  finish
endif
let loaded_gtd = 1

" make todo.gtd define $PWD
  au! BufEnter todo.gtd lcd %:p:h
" define function to open gtd file
  function! s:OpenGTDFile()
     let line = getline('.')
     let line = matchstr(line, "\[.*$") 
     let line = substitute(line, "gtd\]", "gtd", "") 
     let line = substitute(line, "\ *\[", "", "") 
     exec ":e ".line
  endfunction

" bind open function to mouse event 
  nmap <buffer><2-LeftMouse> :call <SID>OpenGTDFile()<CR>

