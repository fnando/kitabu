$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "bookmaker/base"
require "yaml"
require "erb"
require "ostruct"

begin
  require "ruby-debug"
rescue LoadError => e
  nil
end
