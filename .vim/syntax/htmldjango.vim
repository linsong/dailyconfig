" Vim syntax file
" Language:	Django HTML template
" Maintainer:	Dave Hodder <dmh@dmh.org.uk>
" Last Change:	2006 Jul 02

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

if !exists("main_syntax")
  let main_syntax = 'html'
endif

if version < 600
  so <sfile>:p:h/django.vim
  so <sfile>:p:h/html.vim
else
  runtime! syntax/django.vim
  runtime! syntax/html.vim
  unlet b:current_syntax
endif

syn cluster djangoBlocks add=djangoTagBlock,djangoVarBlock,djangoComment

syn region djangoTagBlock start="{%" end="%}" contains=djangoStatement,djangoFilter,djangoArgument display containedin=ALLBUT,@djangoBlocks
syn region djangoVarBlock start="{{" end="}}" contains=djangoFilter,djangoArgument display containedin=ALLBUT,@djangoBlocks
syn region djangoComment start="{%\s*comment\s*%}" end="{%\s*endcomment\s*%}" containedin=ALLBUT,@djangoBlocks

let b:current_syntax = "htmldjango"
