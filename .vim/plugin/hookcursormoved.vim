" hookcursormoved.vim
" @Author:      Thomas Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-10-04.
" @Last Change: 2007-10-11.
" @Revision:    0.3.84
" GetLatestVimScripts: 2037 1 hookcursormoved.vim

if &cp || exists("loaded_hookcursormoved")
    finish
endif
let loaded_hookcursormoved = 3

let s:save_cpo = &cpo
set cpo&vim


augroup HookCursorMoved
    autocmd!
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
