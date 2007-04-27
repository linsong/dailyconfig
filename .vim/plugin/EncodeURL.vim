" EncodeURL.vim
" @Author:      Thomas Link (mailto:samul AT web.de?subject=vim-EncodeURL)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     01-Aug-2005.
" @Last Change: 14-Jun-2006.
" @Revision:    0.1.20

if &cp || exists("loaded_encodeurl")
    finish
endif
let loaded_encodeurl = 1

" fun! DecodeHex(hex)
"     if a:hex == '%'
"         return a:hex
"     else
"         " return escape(nr2char('0x'. a:hex), '\')
"         return nr2char('0x'. a:hex)
"     endif
" endf
"
"fun! DecodeURL(url)
"    let rv = substitute(a:url, '%\(%\|\x\x\)', '\=DecodeHex(submatch(1))', 'g')
"    return rv
"endf

fun! DecodeURL(url)
    let rv = ''
    let n  = 0
    let m  = strlen(a:url)
    while n < m
        let c = a:url[n]
        if c == '+'
            let c = ' '
        elseif c == '%'
            if a:url[n + 1] == '%'
                let n = n + 1
            else
                " let c = escape(nr2char('0x'. strpart(a:url, n + 1, 2)), '\')
                let c = nr2char('0x'. strpart(a:url, n + 1, 2))
                let n = n + 2
            endif
        endif
        let rv = rv.c
        let n = n + 1
    endwh
    return rv
endf

fun! EncodeChar(char)
    if a:char == '%'
        return '%%'
    elseif a:char == ' '
        return '+'
    else
        " Taken from eval.txt
        let n = char2nr(a:char)
        let r = ''
        while n
            let r = '0123456789ABCDEF'[n % 16] . r
            let n = n / 16
        endwhile
        return '%'. r
    endif
endf

" return substitute(a:url, '\(\\\\\|.\)', '\=EncodeChar(submatch(1))', 'g')
fun! EncodeURL(url)
    return substitute(a:url, '\([^a-zA-Z0-9_.-]\)', '\=EncodeChar(submatch(1))', 'g')
endf


