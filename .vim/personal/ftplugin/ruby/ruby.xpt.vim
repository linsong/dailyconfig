XPTemplate priority=personal+
XPTemplateDef


XPT debug " insert debugger 
debugger

XPT debug_include "insert ruby-debug
require "rubygems"
require "ruby-debug"
debugger


XPT tr "require unroller
require 'unroller'
Unroller::trace do
  `cursor^
end

XPT stack "print stack trace
caller.each {|c| puts c}

