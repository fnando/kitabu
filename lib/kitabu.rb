require "rubygems"
require "yaml"
require "erb"
require "ostruct"
require "rexml/streamlistener"
require "rexml/document"
require "hpricot"
require "activesupport"

$LOAD_PATH.unshift File.dirname(__FILE__)

require "kitabu/base"
require "kitabu/toc"
require "kitabu/markup"

begin
  require "ruby-debug"
rescue LoadError => e
  nil
end

module Kitabu
  VERSION = "0.3.10"
end
