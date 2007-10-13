" hookcursormoved.vim
" @Author:      Thomas Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-10-04.
" @Last Change: 2007-10-12.
" @Revision:    0.3.90

if &cp || exists("loaded_hookcursormoved_autoload")
    finish
endif
let loaded_hookcursormoved_autoload = 3


augroup HookCursorMoved
    autocmd!
augroup END


function! s:RunHooks(mode, condition) "{{{3
    let b:hookcursormoved_currpos = getpos('.')
    if hookcursormoved#Test_{a:condition}(a:mode)
        for HookFn in b:hookcursormoved_{a:condition}
            " TLogVAR HookFn
            try
                keepjumps keepmarks call call(HookFn, [a:mode])
            catch
                echohl Error
                echom v:errmsg
                echohl NONE
            endtry
            call setpos('.', b:hookcursormoved_currpos)
            unlet HookFn
        endfor
    endif
    let b:hookcursormoved_oldpos = b:hookcursormoved_currpos
endf


function! hookcursormoved#Enable(condition) "{{{3
    if !exists('b:hookcursormoved_enabled')
        let b:hookcursormoved_enabled = []
    endif
    if index(b:hookcursormoved_enabled, a:condition) == -1
        exec 'autocmd HookCursorMoved CursorMoved  <buffer> call s:RunHooks("n", '. string(a:condition) .')'
        exec 'autocmd HookCursorMoved CursorMovedI <buffer> call s:RunHooks("i", '. string(a:condition) .')'
        call add(b:hookcursormoved_enabled, a:condition)
    endif
endf


" :def: function! hookcursormoved#Register(condition, fn)
function! hookcursormoved#Register(condition, fn, ...) "{{{3
    if exists('*hookcursormoved#Test_'. a:condition)
        call hookcursormoved#Enable(a:condition)
        let var = 'b:hookcursormoved_'. a:condition
        if !exists(var)
            let {var} = [a:fn]
        else
            call add({var}, a:fn)
        endif
    else
        throw 'hookcursormoved: Unknown condition: '. string(a:condition)
    endif
endf


function! hookcursormoved#Test_linechange(mode) "{{{3
    return exists('b:hookcursormoved_oldpos')
                \ && b:hookcursormoved_currpos[1] != b:hookcursormoved_oldpos[1]
endf


function! hookcursormoved#Test_parenthesis(mode) "{{{3
    return stridx('(){}[]', getline('.')[col('.') - 1]) != -1
endf


function! hookcursormoved#Test_syntaxchange(mode) "{{{3
    let syntax = synIDattr(synID(b:hookcursormoved_currpos[1], b:hookcursormoved_currpos[2], 1), 'name')
    if exists('b:hookcursormoved_syntax')
        let rv = b:hookcursormoved_syntax != syntax
    else
        let rv = 0
    endif
    let b:hookcursormoved_syntax = syntax
    return rv
endf


function! hookcursormoved#Test_syntaxleave(mode) "{{{3
    let syntax = synIDattr(synID(b:hookcursormoved_oldpos[1], b:hookcursormoved_oldpos[2], 1), 'name')
    let rv = b:hookcursormoved_syntax != syntax && index(b:hookcursormoved_syntaxleave, syntax) != -1
    let b:hookcursormoved_syntax = syntax
    return rv
endf


function! hookcursormoved#Test_syntaxleave_oneline(mode) "{{{3
    if exists('b:hookcursormoved_oldpos')
        let syntax = synIDattr(synID(b:hookcursormoved_oldpos[1], b:hookcursormoved_oldpos[2], 1), 'name')
        " TLogVAR syntax
        if exists('b:hookcursormoved_syntax') && !empty(syntax)
            " TLogVAR b:hookcursormoved_syntax, syntax
            let rv = b:hookcursormoved_currpos[1] != b:hookcursormoved_oldpos[1]
            " TLogVAR rv, b:hookcursormoved_currpos[1], b:hookcursormoved_oldpos[1]
            if !rv && b:hookcursormoved_syntax != syntax
                let rv = index(b:hookcursormoved_syntaxleave, syntax) != -1
            endif
            " TLogVAR rv
        else
            let rv = 1
        endif
        let b:hookcursormoved_syntax = syntax
        " TLogVAR rv
        return rv
    endif
    return 0
endf


finish

CHANGES
0.1
- Initial release

0.2
- Renamed s:Enable() to hookcursormoved#Enable()
- Renamed s:enabled to b:hookcursormoved_enabled

0.3
- Defined parenthesis, syntaxleave_oneline conditions
- Removed namespace parameter (everything is buffer-local)
- Perform less checks (this should be no problem, if you use #Register).

