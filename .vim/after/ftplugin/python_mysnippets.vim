" python_mysnippets.vim
" @Author:      <+NAME+> (mailto:<+EMAIL+>)
" @Website:     <+WWW+>
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2008-05-08.
" @Last Change: 19-Mai-2005.
" @Revision:    0.0

if !exists('loaded_snippet') || &cp
    finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

exec "Snippet pdb import pdb, readline; pdb.set_trace();"
exec "Snippet log import logging;
\<CR>logging.critical(\"".st.et."\")"
