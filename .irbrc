#!/usr/bin/ruby

require 'rubygems'  unless defined? Gem

require 'irb/completion'
require 'irb/ext/save-history'

IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
IRB.conf[:PROMPT_MODE] = :SIMPLE

class Object
  # list methods which aren't in superclass
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
  
  #print documentation
  
  #  ri 'Array#pop'
  #  Array.ri
  #  Array.ri :pop
  #  arr.ri :pop
  def ri(method = nil)
    unless method && method =~ /^[A-Z]/ # if class isn't specified
      klass = self.kind_of?(Class) ? name : self.class.name
      method = [klass, method].compact.join('#')
    end
    puts `ri '#{method}'`
  end
end

def copy(str)
  IO.popen('pbcopy', 'w') { |f| f << str.to_s }
end

def copy_history
  history = Readline::HISTORY.entries
  index = history.rindex("exit") || -1
  content = history[(index+1)..-2].join("\n")
  puts content
  copy content
end

def paste
  `pbpaste`
end

load File.dirname(__FILE__) + '/.railsrc' if $0 == 'irb' && ENV['RAILS_ENV']

require 'irbtools/configure'
Irbtools.remove_library :wirb
Irbtools.remove_library :fancy_irb
Irbtools.remove_library :boson
Irbtools.add_library :wirb, :thread => -1 do Wirb.start end
Irbtools.add_library :fancy_irb, :thread => -1 do FancyIrb.start end # fancy_irb breaks interactive_editor
Irbtools.start
