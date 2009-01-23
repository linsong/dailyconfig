if !exists('loaded_snippet') || &cp
    finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim
exec "Snippet func CREATE or REPLACE FUNCTION ".st.et." RETURNS ".st.et." AS $$
\<CR>DECLARE
\<CR>".st.et."
\<CR>BEGIN
\<CR>".st.et."
\<CR>END;
\<CR>$$ LANGUAGE plpgsql;"

exec "Snippet for FOR ".st.et." IN ".st.et." LOOP
\<CR>".st.et."
\<CR>END LOOP;"

exec 
