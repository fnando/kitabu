$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Bookmaker
end

require "bookmaker/base"
require "bookmaker/rake"
require "yaml"
require "erb"
require "ostruct"