if !exists('loaded_snippet') || &cp
    finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

exec "Snippet tag <mx:".st."tagName".et."><CR><Tab>".st.et."<CR></mx:".st."tagName".et.">"
exec 'Snippet xml <?xml version="1.0" encoding="utf-8"?>'
exec "Snippet script <mx:Script>
\<CR><Tab><![CDATA[
\<CR><Tab><Tab>".st.et."
\<CR><Tab>]]>
\<CR></mx:Script>"
exec "Snippet Embed @Embed(source='".st.et."') />"




