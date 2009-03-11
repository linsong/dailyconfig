" myconf.vim 
" Author: Vincent Wang (linsong dot qizi at gmail dot com)
" Last Change: 
" Created:  2009/2/3
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

if ! exists("b:mysqlini")

    let b:mysqlini= 1

    setlocal expandtab
    setlocal softtabstop=4

    nmap <buffer> <Enter> :.,.DBExecRangeSQL<CR>
    vmap <buffer> <Enter> :DBExecRangeSQL<CR>

    nmap <buffer> ;f :.,.SQLUFormatter<CR>
    vmap <buffer> ;f :SQLUFormatter<CR>
    """ This is not needed since python_match.vim defined these already
    "if !exists("b:match_words")
        "let b:match_ignorecase=0
        "let b:match_words = 'if:elif:else,' .
                    "\ 'try:except' .
                    "\ 'from:import' .

    "endif
endif
