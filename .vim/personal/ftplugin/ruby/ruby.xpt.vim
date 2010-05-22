XPTemplate priority=personal+

" inclusion
XPTinclude
      \ _common/common

XPTemplateDef

XPT debug " insert debugger 
debugger

XPT debug_include "insert ruby-debug
require "rubygems"
require "ruby-debug"
debugger

XPT di alias=debug_include "insert ruby-debug

XPT tr "require unroller
require 'unroller'
Unroller::trace do
	`cursor^
end

XPT stack "print stack trace
caller.each {|c| puts c}

XPT module "module self.included .. ClassMethods .. InstanceMethods end
XSET name=fileRoot()
XSET name|post=RubyCamelCase()
module `name^
	
	def self.included(receiver)
	  receiver.extend         ClassMethods
	  receiver.send :include, InstanceMethods
	end
	
	module ClassMethods
	  `^
	end
	
	module InstanceMethods
	  `cursor^
	end
	
end

XPT class "class .. end
XSET name=fileRoot()
XSET name|post=RubyCamelCase()
XSET parent|post=RubyCamelCase()
class `name^ `parent...{{^` < `parent^`}}^
	`cursor^
end
