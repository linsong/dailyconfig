if !exists('g:loaded_snips') || exists('s:did_actionscript_mysnips_snips')
     finish
endif
let s:did_actionscript_mysnips_snips = 1
let snippet_file = 'actionscript_mysnips'
let snippet_filetype = 'actionscript'

exec "Snipp function ${1:public} function ${2}(${3}):${3:void} {
\\n${4}
\\n}"

exec "Snipp Embed [Embed(source='${1}')]"
exec "Snipp var ${1:public} var ${2}:${3};"
exec "Snipp if if(${1})\n{\n${2}\n}\n"
exec "Snipp for for( ${1} ${2:i} = ${3}; $2 < ${4:count}; $2 += ${5})\n{\n${6}\n}\n"


