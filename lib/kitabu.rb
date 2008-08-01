$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "rubygems"
require "yaml"
require "erb"
require "ostruct"
require "rexml/streamlistener"
require "rexml/document"
require "hpricot"

require "kitabu/base"

begin
  require "ruby-debug"
rescue LoadError => e
  nil
end
