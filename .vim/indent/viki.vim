" viki.vim -- viki indentation
" @Author:      Thomas Link (samul AT web.de)
" @Website:     http://members.a1.net/t.link/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     16-J?n-2004.
" @Last Change: 2007-07-17.
" @Revision: 0.258

if !g:vikiEnabled
    finish
endif

if exists("b:did_indent") || exists("g:vikiNoIndent")
    finish
endif
let b:did_indent = 1

" Possible values: 'sw', '::'
if !exists("g:vikiIndentDesc") | let g:vikiIndentDesc = 'sw' | endif "{{{2

setlocal indentexpr=VikiGetIndent()
" setlocal indentkeys&
setlocal indentkeys=0=#\ ,0=?\ ,0=<*>\ ,0=-\ ,0=+\ ,0=@\ ,=::\ ,!^F,o,O
" setlocal indentkeys=0=#<space>,0=?<space>,0=<*><space>,0=-<space>,=::<space>,!^F,o,O,e

" Define the function only once.
if exists("*VikiGetIndent")
    finish
endif

fun! VikiGetIndent()
    let lr = &lazyredraw
    set lazyredraw
    try
        " Find a non-blank line above the current line.
        let lnum = prevnonblank(v:lnum - 1)

        " At the start of the file use zero indent.
        if lnum == 0
            " TLogVAR lnum
            return 0
        endif

        let ind  = indent(lnum)
        " if ind == 0
        "     TLogVAR ind
        "     return 0
        " end

        let line = getline(lnum)      " last line
        
        let cnum  = v:lnum
        let cind  = indent(cnum)
        let cline = getline(cnum)
        
        " Do not change indentation in regions
        if VikiIsInRegion(cnum)
            " TLogVAR cnum, cind
            return cind
        endif
        
        let cHeading = matchend(cline, '^\*\+\s\+')
        if cHeading >= 0
            " TLogVAR cHeading
            return 0
        endif
            
        let pnum   = v:lnum - 1
        let pind   = indent(pnum)
        
        let pline  = getline(pnum) " last line
        let plCont = matchend(pline, '\\$')
        
        if plCont >= 0
            " TLogVAR plCont, cind
            return cind
        end
        
        if cind > 0
            " TLogVAR cind
            " Do not change indentation of:
            "   - commented lines
            "   - headings
            if cline =~ '^\(\s*%\|\*\)'
                " TLogVAR cline, ind
                return ind
            endif

            let markRx = '^\s\+\([#?!+]\)\1\{2,2}\s\+'
            let listRx = '^\s\+\([-+*#?@]\|[0-9#]\+\.\|[a-zA-Z?]\.\)\s\+'
            let priRx  = '^\s\+#[A-F]\d\? \+\([x_0-9%-]\+ \+\)\?'
            let descRx = '^\s\+.\{-1,}\s::\s\+'
            
            let clMark = matchend(cline, markRx)
            let clList = matchend(cline, listRx)
            let clPri  = matchend(cline, priRx)
            let clDesc = matchend(cline, descRx)
            " let cln    = clList >= 0 ? clList : clDesc

            if clList >= 0 || clDesc >= 0 || clMark >= 0 || clPri >= 0
                let spaceEnd = matchend(cline, '^\s\+')
                let rv = (spaceEnd / &sw) * &sw
                " TLogVAR clList, clDesc, clMark, clPri, rv
                return rv
            else
                let plMark = matchend(pline, markRx)
                if plMark >= 0
                    " TLogVAR plMark
                    return plMark
                endif
                
                let plList = matchend(pline, listRx)
                if plList >= 0
                    " TLogVAR plList
                    return plList
                endif

                let plPri = matchend(pline, priRx)
                if plPri >= 0
                    let rv = indent(pnum) + &sw / 2
                    " TLogVAR plPri, rv
                    " return plPri
                    return rv
                endif

                let plDesc = matchend(pline, descRx)
                if plDesc >= 0
                    " TLogVAR plDesc, pind
                    if plDesc >= 0 && g:vikiIndentDesc == '::'
                        return plDesc
                    else
                        return pind + (&sw / 2)
                    endif
                endif

                " TLogVAR cind, ind, rv
                if cind < ind
                    let rv = (cind / &sw) * &sw
                    return rv
                elseif cind >= ind
                    if cind % &sw == 0
                        return cind
                    else
                        return ind
                    end
                endif
            endif
        endif

        " TLogVAR ind
        return ind
    finally
        let &lazyredraw = lr
    endtry
endf

