if !exists('g:loaded_snips') || exists('s:did_htmldjango_mysnips_snips')
     finish
endif
let s:did_htmldjango_mysnips_snips = 1
let snippet_file = 'htmldjango_mysnips'
let snippet_filetype = 'htmldjango'

exec "Snipp blocktrans {% blocktrans ${1} %} ${2} {% endblocktrans %}"
exec "Snipp trans {% trans ${1} %} "

