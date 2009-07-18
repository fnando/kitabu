require "rubygems"
require "yaml"
require "erb"
require "ostruct"
require "rexml/streamlistener"
require "rexml/document"
require "hpricot"

require "kitabu/base"
require "kitabu/toc"
require "kitabu/markup"

begin
  require "ruby-debug"
rescue LoadError => e
  nil
end
