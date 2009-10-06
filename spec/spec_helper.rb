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
require "hpricot"
require "nokogiri"

require File.dirname(__FILE__) + "/exit_matcher"

Spec::Runner.configure do |config|
  config.include(HpricotSpec::Matchers)
  config.include(ExitMatcher)
end

def reset_env!
  ENV["KITABU_ROOT"] = File.dirname(__FILE__) + "/fixtures/rails-guides"
  ENV["KITABU_NAME"] = File.basename(ENV["KITABU_ROOT"])
  ENV.delete("NO_SYNTAX_HIGHLIGHT")
end

alias :doing :lambda