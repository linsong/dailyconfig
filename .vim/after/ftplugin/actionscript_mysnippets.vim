if !exists('loaded_snippet') || &cp
    finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

exec "Snippet function ".st."public".et." function ".st.et."(".st.et."):".st."void".et." {
\<CR>".st.et."
\<CR>}"

exec "Snippet Embed [Embed(source='".st.et."')]"
exec "Snippet var ".st."public".et." var ".st.et.":".st.et.";"
exec "Snippet if if(".st.et.")<CR>{<CR>".st.et."<CR>}<CR>".st.et
exec "Snippet for for( ".st.et." ".st."i".et." = ".st.et."; ".st."i".et." < ".st."count".et."; ".st."i".et." += ".st.et.")<CR>{<CR>".st.et."<CR>}<CR>".st.et


