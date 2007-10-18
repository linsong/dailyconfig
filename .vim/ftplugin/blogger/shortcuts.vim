" shortcuts.vim
" @Author:      <+NAME+> (mailto:<+EMAIL+>)
" @Website:     <+WWW+>
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-10-18.
" @Last Change: 19-Mai-2005.
" @Revision:    0.0

if ! exists("b:mypyini")
    let b:mypyini= 1
    nnoremap <buffer> ,bp :BlogPost<CR>
    nnoremap <buffer> ,bf :BlogDraft<CR>
    nnoremap <buffer> ,bi :BlogIndex<CR>
    nnoremap <buffer> ,bq :BlogQuery<CR>
    nnoremap <buffer> ,bd :BlogDelete<CR>
endif



