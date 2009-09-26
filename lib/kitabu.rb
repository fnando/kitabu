# encoding: utf-8
require "rubygems"
require "yaml"
require "erb"
require "ostruct"
require "rexml/streamlistener"
require "rexml/document"
require "activesupport"

$:.unshift File.dirname(__FILE__)

require "kitabu/base"
require "kitabu/toc"
require "kitabu/syntax"
require "kitabu/templates"

vendor = File.dirname(__FILE__) + "/kitabu/vendor/"

dir = RUBY_VERSION =~ /^1.9/ ? "ruby1.9" : "ruby1.8"

$:.unshift File.join(vendor, dir, "plist")
$:.unshift File.join(vendor, dir, "textpow")
$:.unshift File.join(vendor, dir, "uv")
$:.unshift File.join(vendor, "colorize")

begin
  require "nokogiri"
rescue LoadError
  nil
end

begin
  require "hpricot"
rescue LoadError
  nil
end unless defined?(Nokogiri)

require "colorize"

begin
  require "plist"
  require "textpow"
  require "uv"
rescue LoadError => e
  NO_SYNTAX_HIGHLIGHT = true
end

module Kitabu
  VERSION = "0.4.1"
end
