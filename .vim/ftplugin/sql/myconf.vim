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

    "nmap <buffer> <Enter> :.,.DBExecRangeSQL<CR>
    "vmap <buffer> <Enter> :DBExecRangeSQL<CR>

    function! SmartExecSQL()
      if len(split(getline('.'), '\s\+')) == 1
        :DBSelectFromTable
      else
        if mode() == 'V'
          :DBExecRangeSQL
        else
          :.,.DBExecRangeSQL
        endif
      endif
    endfunction

    nmap <buffer> <Enter> :call SmartExecSQL()<CR>
    vmap <buffer> <Enter> :call SmartExecSQL()<CR>

    nmap <buffer> ;f :.,.SQLUFormatter<CR>
    vmap <buffer> ;f :SQLUFormatter<CR>
endif
