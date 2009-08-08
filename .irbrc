begin
  require 'rubygems' rescue nil
  # load wirble
  require 'wirble'

  # start wirble (with color)
  Wirble.init
  Wirble.colorize
rescue LoadError => err
  warn "Couldn't load Wirble: #{err}"
end

def ri(*names) 
    system(%{ri #{names.map {|name| name.to_s}.join(" ")}}) 
end 

