" Vim ftdetect file
" Language:	GTD (pyGTD)
" Version:      1.1
" Maintainer:	Michael M. Tung <mtung@mat.upv.es>
" Last Change:  Wed Nov 01 16:57:46 CET 2006

" A fast syntax hack for pyGTD todo and context files by Keith Martin.
" Check the webpage http://96db.com/pyGTD/ for the program and documentation.
" This plugin file is still in development. Please send suggestions
" to the maintainer.

" make gtd filetype
augroup filetypedetect
  au! BufRead,BufNewFile *.gtd	set filetype=gtd
augroup END

