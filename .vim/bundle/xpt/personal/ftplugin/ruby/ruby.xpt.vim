XPTemplate priority=personal+
XPTemplateDef

XPT d " insert debugger 
debugger

XPT dd "insert ruby-debug
require "rubygems"
require "ruby-debug"


XPT tr "require unroller
require 'unroller'
Unroller::trace do
  `cursor^
end

XPT stack "print stack trace
caller.each {|c| puts c}

