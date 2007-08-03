" viki.vim -- the viki ftplugin
" @Author:      Thomas Link (samul AT web.de)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     12-J?n-2004.
" @Last Change: 2007-07-10.
" @Revision: 316

" if !g:vikiEnabled
"     finish
" endif

if exists("b:did_ftplugin") "{{{2
    finish
endif
let b:did_ftplugin = 1
" if exists("b:did_viki_ftplugin")
"     finish
" endif
" let b:did_viki_ftplugin = 1

let b:vikiCommentStart = "%"
let b:vikiCommentEnd   = ""
let b:vikiHeadingMaxLevel = 0
if !exists("b:vikiMaxFoldLevel") | let b:vikiMaxFoldLevel = 5 | endif "{{{2
if !exists("b:vikiInverseFold")  | let b:vikiInverseFold  = 0 | endif "{{{2

exe "setlocal commentstring=". substitute(b:vikiCommentStart, "%", "%%", "g") 
            \ ."%s". substitute(b:vikiCommentEnd, "%", "%%", "g")
exe "setlocal comments=:". b:vikiCommentStart

setlocal foldmethod=expr
setlocal foldexpr=VikiFoldLevel(v:lnum)
setlocal foldtext=VikiFoldText()
setlocal expandtab
setlocal iskeyword+=#,{

let &include='\(^\s*#INC.\{-}\(\sfile=\|:\)\)'
" let &include='\(^\s*#INC.\{-}\(\sfile=\|:\)\|\[\[\)'
" set includeexpr=substitute(v:fname,'\].*$','','')

let &define='^\s*\(#Def.\{-}id=\|#\(Fn\|Footnote\).\{-}\(:\|id=\)\|#VAR.\{-}\s\)'

" if !exists('b:vikiHideBody') | let b:vikiHideBody = 0 | endif

" if !hasmapto(":VikiFind")
"     nnoremap <buffer> <c-tab>   :VikiFindNext<cr>
"     nnoremap <buffer> <LocalLeader>vn :VikiFindNext<cr>
"     nnoremap <buffer> <c-s-tab> :VikiFindPrev<cr>
"     nnoremap <buffer> <LocalLeader>vN :VikiFindPrev<cr>
" endif

" compiler deplate

map <buffer> <silent> [[ :call VikiFindPrevHeading()<cr>
map <buffer> <silent> ][ :call VikiFindNextHeading()<cr>
map <buffer> <silent> ]] ][
map <buffer> <silent> [] [[

let b:undo_ftplugin = 'setlocal iskeyword< expandtab< foldtext< foldexpr< foldmethod< comments< commentstring< '
            \ .'define< include<'
            \ .'| unlet b:vikiHeadingMaxLevel b:vikiCommentStart b:vikiCommentEnd b:vikiInverseFold b:vikiMaxFoldLevel '
            \ .' b:vikiEnabled '
            \ .'| unmap <buffer> [['
            \ .'| unmap <buffer> ]]'
            \ .'| unmap <buffer> ]['
            \ .'| unmap <buffer> []'

let b:vikiEnabled = 2

if exists('*VikiFoldLevel') "{{{2
    finish
endif

function! VikiFoldText() "{{{3
  let line = getline(v:foldstart)
  if synIDattr(synID(v:foldstart, 1, 1), 'name') =~ '^vikiFiles'
      let line = fnamemodify(viki#VikiFilesGetFilename(line), ':h')
  else
      let line = matchstr(line, '^\s*\zs.*$')
  endif
  return v:folddashes . line
endf

if g:vikiFoldMethodVersion == 3

    function! VikiFoldLevel(lnum) "{{{3
        let lt = getline(a:lnum)
        let fh = matchend(lt, '\V\^'. b:vikiHeadingStart .'\+\ze\s')
        if fh != -1
            if fh > b:vikiHeadingMaxLevel
                let b:vikiHeadingMaxLevel = fh
                " TLogVAR b:vikiHeadingMaxLevel
            endif
            " TLogVAR fh
            return fh
        endif
        if lt !~ '\S'
            return '='
        endif
        let li = indent(a:lnum)
        let tf = b:vikiHeadingMaxLevel + 1 + (li / &sw)
        " TLogVAR tf
        return tf
    endf

elseif g:vikiFoldMethodVersion == 2

    function! VikiFoldLevel(lnum) "{{{3
        let lt = getline(a:lnum)
        let fh = matchend(lt, '\V\^'. b:vikiHeadingStart .'\+\ze\s')
        if fh != -1
            return fh
        endif
        let ll = prevnonblank(a:lnum)
        if ll != a:lnum
            return '='
        endif
        let li = indent(a:lnum)
        let pl = prevnonblank(a:lnum - 1)
        let pi = indent(pl)
        if li == pi || pl == 0
            return '='
        elseif li > pi
            return 'a'. ((li - pi) / &sw)
        else
            return 's'. ((pi - li) / &sw)
        endif
    endf

else

    function! VikiFoldLevel(lnum) "{{{3
        let lc = getpos('.')
        " TLogVAR lc
        let w0 = line('w0')
        let lr = &lazyredraw
        set lazyredraw
        try
            let vikiFolds = tlib#var#Get('vikiFolds', 'bg')
            if vikiFolds == 'ALL'
                let vikiFolds = 'hHlsfb'
            elseif vikiFolds == 'DEFAULT'
                let vikiFolds = 'hf'
            elseif vikiFolds == ''
                " TLogDBG 'no folds'
                return
            endif
            if vikiFolds =~# 'f'
                let idt = indent(a:lnum)
                if synIDattr(synID(a:lnum, idt, 1), 'name') =~ '^vikiFiles'
                    call s:SetHeadingMaxLevel(1)
                    " TLogDBG 'vikiFiles: '. idt
                    return b:vikiHeadingMaxLevel + idt / &shiftwidth
                endif
            endif
            if stridx(vikiFolds, 'h') >= 0
                if vikiFolds =~? 'h'
                    let fl = s:ScanHeading(a:lnum, a:lnum, vikiFolds)
                    if fl != ''
                        " TLogDBG 'heading: '. fl
                        return fl
                    endif
                endif
                if vikiFolds =~# 'l' 
                    let list = s:MatchList(a:lnum)
                    if list > 0
                        call s:SetHeadingMaxLevel(1)
                        " TLogVAR list
                        " return '>'. (b:vikiHeadingMaxLevel + (list / &sw))
                        return (b:vikiHeadingMaxLevel + (list / &sw))
                    elseif getline(a:lnum) !~ '^[[:blank:]]' && s:MatchList(a:lnum - 1) > 0
                        let fl = s:ScanHeading(a:lnum - 1, 1, vikiFolds)
                        if fl != ''
                            if fl[0] == '>'
                                let fl = strpart(fl, 1)
                            endif
                            " TLogDBG 'list indent: '. fl
                            return '<'. (fl + 1)
                        endif
                    endif
                endif
                " I have no idea what this is about.
                " Is this about "inverse" folding?
                " if vikiFolds =~# 's'
                "     if exists('b:vikiFoldDef')
                "         exec b:vikiFoldDef
                "         if vikiFoldLine == a:lnum
                "             return vikiFoldLevel
                "         endif
                "     endif
                "     let i = 1
                "     while i > a:lnum
                "         let vfl = VikiFoldLevel(a:lnum - i)
                "         if vfl[0] == '>'
                "             let b:vikiFoldDef = 'let vikiFoldLine='. a:lnum 
                "                         \ .'|let vikiFoldLevel="'. vfl .'"'
                "             return vfl
                "         elseif vfl == '='
                "             let i = i + 1
                "         endif
                "     endwh
                " endif
                call s:SetHeadingMaxLevel(1)
                " if b:vikiHeadingMaxLevel == 0
                "     return 0
                " elseif vikiFolds =~# 'b'
                if vikiFolds =~# 'b'
                    let bl = exists('b:vikiFoldBodyLevel') ? b:vikiFoldBodyLevel : g:vikiFoldBodyLevel
                    if bl > 0
                        " TLogDBG 'body: '. bl
                        return bl
                    else
                        " TLogDBG 'body fallback: '. b:vikiHeadingMaxLevel
                        return b:vikiHeadingMaxLevel + 1
                    endif
                else
                    " TLogDBG 'else'
                    return "="
                endif
            endif
            " TLogDBG 'zero'
            return 0
        finally
            exec 'norm! '. w0 .'zt'
            " TLogVAR lc
            call setpos('.', lc)
            let &lazyredraw = lr
        endtry
    endfun

    function! s:ScanHeading(lnum, top, vikiFolds) "{{{3
        " TLogVAR a:lnum, a:top
        let [lhead, head] = s:SearchHead(a:lnum, a:top)
        " TLogVAR head
        if head > 0
            if head > b:vikiHeadingMaxLevel
                let b:vikiHeadingMaxLevel = head
            endif
            if b:vikiInverseFold || a:vikiFolds =~# 'H'
                if b:vikiMaxFoldLevel > head
                    return ">". (b:vikiMaxFoldLevel - head)
                else
                    return ">0"
                end
            else
                return ">". head
            endif
        endif
        return ''
    endf

    function! s:SetHeadingMaxLevel(once) "{{{3
        if a:once && b:vikiHeadingMaxLevel != 0
            return
        endif
        let pos = getpos('.')
        " TLogVAR pos
        try
            silent! keepjumps exec 'g/\V\^'. b:vikiHeadingStart .'\+\s/call s:SetHeadingMaxLevelAtCurrentLine(line(".")'
        finally
            " TLogVAR pos
            call setpos('.', pos)
        endtry
    endf

    function! s:SetHeadingMaxLevelAtCurrentLine(lnum) "{{{3
        let m = s:MatchHead(lnum)
        if m > b:vikiHeadingMaxLevel
            let b:vikiHeadingMaxLevel = m
        endif
    endf

    function! s:SearchHead(lnum, top) "{{{3
        let pos = getpos('.')
        " TLogVAR pos
        try
            exec a:lnum
            norm! $
            let ln = search('\V\^'. b:vikiHeadingStart .'\+\s', 'bWcs', a:top)
            if ln
                return [ln, s:MatchHead(ln)]
            endif
            return [0, 0]
        finally
            " TLogVAR pos
            call setpos('.', pos)
        endtry
    endf

    function! s:MatchHead(lnum) "{{{3
        " let head = matchend(getline(a:lnum), '\V\^'. escape(b:vikiHeadingStart, '\') .'\ze\s\+')
        return matchend(getline(a:lnum), '\V\^'. b:vikiHeadingStart .'\+\ze\s')
    endf

    function! s:MatchList(lnum) "{{{3
        let rx = '^[[:blank:]]\+\ze\(#[A-F]\d\?\|#\d[A-F]\?\|[-+*#?@]\|[0-9#]\+\.\|[a-zA-Z?]\.\|.\{-1,}[[:blank:]]::\)[[:blank:]]'
        return matchend(getline(a:lnum), rx)
    endf

endif
