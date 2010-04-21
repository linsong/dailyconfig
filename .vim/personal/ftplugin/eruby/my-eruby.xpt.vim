XPTemplate priority=personal+
XPTemplateDef

XPT %
<% `^ %>`cursor^


XPT =
<%= `^ %>`cursor^


XPT if
<% if `^ -%>
  `cursor^
<% end -%>


XPT end
<% end %>


XPT check
<%= check_box_tag `cursor^ %>


XPT hidden
<%= hidden_field_tag '`^' %>


XPT text
<%= text_field_tag '`^' %>


XPT texta
<%= text_area_tag '`^' %>


XPT formt
<% form_tag :action => "`update^" -%>
  <%= `^ %>
<% end -%>


XPT formf
<% form_for @`^ do |`f^| %>
  <%= `f^.error_messages %>
  <%= `f^.label :`cursor^ %>
<% end %>


XPT link
<%= link_to :action => "`index^" %>`cursor^


XPT rf
render :file => "`filepath^"


XPT rfu
render :file => "`filepath^", :use_full_path => `false^


XPT ri
render :inline => "`<%= 'hello' %>^"


XPT ril
render :inline => "`<%= 'hello' %>^", :locals => { `name^ => "`value^" }


XPT rit
render :inline => "`<%= 'hello' %>^", :type => :`rxml^)


XPT rl
render :layout => "`layoutname^"


XPT rn
render :nothing => `true^


XPT rns
render :nothing => `true^, :status => `401^


XPT rp
render :partial => "`item^"


XPT rpc
render :partial => "`item^", :collection => `items^


XPT rpl
render :partial => "`item^", :locals => { :`name^ => "`value^"}


XPT rpo
render :partial => "`item^", :object => `object^


XPT rps
render :partial => "`item^", :status => `500^


XPT rt
render :text => "`Text here...^"


XPT rtl
render :text => "`Text here...^", :layout => "`layoutname^"


XPT rtlt
render :text => "`Text here...^", :layout => `true^


XPT rts
render :text => "`Text here...^", :status => `401^


XPT d
<% debugger %>

