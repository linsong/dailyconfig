XPTemplate priority=personal+
XPTemplateDef

XPT setup "setup ...
setup do 
  `content^
end

XPT should "should ...
should "`description^" do
  `cursor^
end

XPT cont "context"
context "`description^" do
  `setup...{{^`:setup:^
  `}}^
  `should...{{^`:should:^ `}}^
end

XPT laf "load_all_fixtures"
load_all_fixtures


XPT should_allow_values_for "should_allow_values_for"
should_allow_values_for :`attribute^, "`^"`...{{^, "`^"`...{{^, "`^"`}}^`}}^


XPT should_assign_to "should_assign_to"
should_assign_to :`variable^


XPT should_be_restful "should_be_restful denied"
should_be_restful do |resource|
  resource.denied.actions  = :`all^
  resource.denied.flash    = /`must be logged in^/i
  resource.denied.redirect = '`login_url^'
end


XPT should_be_restful "should_be_restful"
should_be_restful do |resource|
  resource.formats = [:html]
  `resource.`something^^
end
`cursor^


XPT should_belong_to "should_belong_to"
should_belong_to :`object^


XPT should_ensure_length_in_range "should_ensure_length_in_range"
should_ensure_length_in_range `attribute^, (`range^)


XPT should_ensure_value_in_range "should_ensure_value_in_range"
should_ensure_value_in_range `attribute^, (`range^)


XPT should_have_and_belong_to_many "should_have_and_belong_to_many"
should_have_and_belong_to_many :`object^`, :`object...{{^, `object^`}}^


XPT should_have_class_methods "should_have_class_methods"
should_have_class_methods :`method^`, :`method...{{^, `method^`}}^


XPT should_have_instance_methods "should_have_instance_methods"
should_have_instance_methods :`method^`, :`method...{{^, `method^`}}^


XPT should_have_many "should_have_many"
should_have_many :`objects^, :through => `association^


XPT should_have_one "should_have_one"
should_have_one :`object^


XPT should_not_allow_values_for "should_not_allow_values_for"
should_not_allow_values_for :`attribute^, "`^", "`^"`...{{^, "`^"`}}^


XPT should_not_assign_to "should_not_assign_to"
should_not_assign_to :`variable^


XPT should_not_set_the_flash "should_not_set_the_flash"
should_not_set_the_flash


XPT should_only_allow_numeric_values_for "should_only_allow_numeric_values_for"
should_only_allow_numeric_values_for :`attribute^


XPT should_protect_attributes "should_protect_attributes"
should_protect_attributes :`attribute^`, :`attribute...{{^, `attribute^`}}^


XPT should_render_a_form "should_render_a_form"
should_render_a_form


XPT should_render_template "should_render_template"
should_render_template :`template^


XPT should_require_attributes "should_require_attributes"
should_require_attribute `attribute^


XPT should_require_unique_attributes "should_require_unique_attributes"
should_require_unique_attributes `attributes^


XPT should_respond_with "should_respond_with"
should_respond_with :`response^


XPT should_set_the_flash_to "should_set_the_flash_to"
shuold_set_the_flash_to `value^


