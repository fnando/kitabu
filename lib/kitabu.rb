require "rubygems"
require "yaml"
require "erb"
require "ostruct"
require "rexml/streamlistener"
require "rexml/document"

require "hpricot"
require "activesupport"

$:.unshift File.dirname(__FILE__)

require "kitabu/base"
require "kitabu/toc"
require "kitabu/syntax"

vendor = File.dirname(__FILE__) + "/kitabu/vendor/"

$LOAD_PATH.unshift File.join(vendor, "colorize")
dir = RUBY_VERSION =~ /^1.9/ ? "ruby1.9" : "ruby1.8"

$:.unshift File.join(vendor, dir, "plist")
$:.unshift File.join(vendor, dir, "textpow")
$:.unshift File.join(vendor, dir, "uv")
$:.unshift File.join(vendor, "colorize")

require "colorize"

begin
  require "plist"
  require "textpow"
  require "uv"
rescue LoadError => e
  NO_SYNTAX_HIGHLIGHT = true
end

begin
  require "ruby-debug"
rescue LoadError => e
  nil
end

module Kitabu
  VERSION = "0.4.0"
end
