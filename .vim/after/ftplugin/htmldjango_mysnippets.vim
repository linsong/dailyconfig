if !exists('loaded_snippet') || &cp
    finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

exec "Snippet blocktrans {% blocktrans ".st.et." %} ".st.et." {% endblocktrans %}"
exec "Snippet trans {% trans ".st.et." %} "

