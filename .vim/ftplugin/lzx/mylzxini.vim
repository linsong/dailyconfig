" mylzxini.vim 
" Author: Vincent Wang (linsong dot qizi at gmail dot com)
" Last Change: 
" Created:     
" Requires: 
" Version: 
" Acknowledgements:

" prevent reloading twice for the same buffer
" for buffer related setting, we need to call it every buffer
" buffer related setting includes: 
"     * variables in buffer scope 
"     * buffer abbreviation
"     * buffer map
"     * settings set by setlocal
"
runtime! ftplugin/xml/xml.vim

if ! exists("b:mylzxini")
    let b:mylzxini = 1

    setlocal expandtab
    setlocal autoindent
    setlocal smartindent

    " fold the class and method when we begin to edit source 
    " and this will let us to view more source in one page
    ":FoldMatching ^\s*\(def\|class\) -1 
    
    iabbr <buffer> self this

    "add a suffix to the possible filename
    setlocal suffixesadd+=.lzx
endif

" prevent re-load
if exists("g:mylzxini")
  finish
endif

let g:mylzxini= 1
"set textwidth=79

"############################################################################
"#    FUNCTIONS 
"############################################################################
" use the foldutil.vim to fold opened python file 
"function! LzxFold(fold)
    "if a:fold==1
        "" fold the class and method when we begin to edit source 
        "" and this will let us to view more source in one page
        ":FoldMatching <method\|<class -1
    "else
        ":FoldEndFolding
    "endif
"endfunction

"############################################################################
"#    AUTOCOMMAND 
"############################################################################
au BufEnter *.lzx set path+=/usr/local/lps-3.0/Server/lps-3.0/lps/components/**
au BufLeave *.lzx set path-=/usr/local/lps-3.0/Server/lps-3.0/lps/components/**

"au BufEnter *.lzx
            "\ if g:mylzxini==1 | 
            "\    if ! exists("b:LzxInitFold") |
            "\        call LzxFold(1) |
            "\        let b:LzxInitFold = 1 |
            "\    endif |
            "\ endif
" the end 
