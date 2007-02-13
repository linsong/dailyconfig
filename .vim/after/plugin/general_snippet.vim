" prevent reloading twice for the same type of file 
if exists("g:general_snippet")
    finish
endif

let g:general_snippet = 1

Iabbr date` <:strftime('%b %d %Y')><CR> 

:call IMAP('date`', "\<c-r>=strftime('%b %d %Y')\<cr>", '')
:call IMAP('if`', "if <++>:\<cr>\<++>", "python")
:call IMAP('<method', "<method name=\"<++>\" args=\"<++>\">\<cr>\<tab><![CDATA[\<cr>\<tab><++>\<cr>]]>\<cr></method>", 'lzx')

