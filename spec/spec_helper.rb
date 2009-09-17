require "rubygems"
require "spec"
require "rspec-hpricot-matchers"

$LOAD_PATH << File.dirname(__FILE__) + "/../lib"

require "kitabu"

# Do require libs that are required by the tasks.rb file
require "kitabu/redcloth"
require "kitabu/blackcloth"
require "uv"

KITABU_ROOT = File.dirname(__FILE__) + "/fixtures/rails-guides"
ENV["KITABU_NAME"] = File.basename(KITABU_ROOT)

Spec::Runner.configure do |config|
  config.include(HpricotSpec::Matchers)
end
