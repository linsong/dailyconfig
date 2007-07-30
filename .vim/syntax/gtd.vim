" Vim syntax file
" Language:	GTD (pyGTD)
" Version:      1.1
" Maintainer:	Michael M. Tung <mtung@mat.upv.es>
" Last Change:  Wed Nov 01 17:19:03 CET 2006

" A fast syntax hack for pyGTD todo and context files by Keith Martin.
" Check the webpage http://96db.com/pyGTD/ for the program and documentation.
" This syntax file is still in development. Please send suggestions
" to the maintainer.

if exists("b:current_syntax")
  finish
endif

syn case ignore

" pattern matching
syn match    gtdRating		"^\<\d\+\.\d*\>"
syn match    gtdTiming		"\ \<\d\+:\d*\>\ "
syn match    gtdContextPath	"\[.*gtd\]"
syn region   gtdTitle		display oneline start='^[0-9]' end='$' contains=gtdRating,gtdTiming
syn region   gtdTitle		display oneline start='^\*' end='$'
syn region   gtdStatus		display oneline start='C=' end='ID=[0-9]\+'

" highlight labels
hi def link gtdRating		Macro
"hi def link gtdTiming		Number
hi def link gtdTitle		Keyword
hi def link gtdStatus		Macro
hi def link gtdContextPath	Comment

let b:current_syntax = "gtd"

" vim: ts=8
