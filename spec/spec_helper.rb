# encoding: utf-8
require "rubygems"
require "spec"
require "rspec-hpricot-matchers"

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")

require "kitabu"

# Do require libs that are used by the tasks.rb file
require "kitabu/redcloth"
require "kitabu/blackcloth"
require "rdiscount"

require File.dirname(__FILE__) + "/exit_matcher"

KITABU_ROOT = File.dirname(__FILE__) + "/fixtures/rails-guides"
ENV["KITABU_NAME"] = File.basename(KITABU_ROOT)

Spec::Runner.configure do |config|
  config.include(HpricotSpec::Matchers)
  config.include(ExitMatcher)
end

alias :doing :lambda