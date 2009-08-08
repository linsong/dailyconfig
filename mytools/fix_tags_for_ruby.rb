#! /usr/bin/env ruby

#require "rubygems"
#require "ruby-debug"

result = []
File.open(ARGV[0]) do |f|
  f.readlines.each do |line|
    parts = line.split("\t")
    if !parts[3].nil? && (parts[3].start_with?('c') || parts[3].start_with?('m'))
      parts[2] =~ %r{/\^\s*(?:class|module)\s+(?:\w+::)*(\w+)\b}
      parts[0] = $1
    end
    result << parts.join("\t")
  end
end

File.open(ARGV[0], "w") do |f|
  f.write(result.join)
end

