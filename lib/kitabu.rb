require "active_support/all"
require "digest/md5"
require "eeepub"
require "erb"
require "nokogiri"
require "notifier"
require "optparse"
require "ostruct"
require "RedCloth"
require "tempfile"
require "thor"
require "thor/group"
require "watchr"
require "yaml"

%w[maruku peg_markdown bluecloth rdiscount].each do |lib|
  begin
    require lib
    break
  rescue LoadError => e
    next
  end
end

dir = RUBY_VERSION =~ /^1.9/ ? "ruby1.9" : "ruby1.8"

%w[plist textpow uv].each do |lib|
  $LOAD_PATH.unshift File.dirname(__FILE__) + "/kitabu/vendor/#{dir}/#{lib}"
  require lib
end

module Kitabu
  require "kitabu/extensions/string"
  require "kitabu/extensions/redcloth"
  require "kitabu/errors"

  ROOT = Pathname.new(File.dirname(__FILE__) + "/..")

  autoload :Version,    "kitabu/version"
  autoload :Generator,  "kitabu/generator"
  autoload :Toc,        "kitabu/toc"
  autoload :Cli,        "kitabu/cli"
  autoload :Parser,     "kitabu/parser"
  autoload :Exporter,   "kitabu/exporter"
  autoload :Syntax,     "kitabu/syntax"
  autoload :Stream,     "kitabu/stream"

  def self.config(root_dir = nil)
    YAML.load_file(root_dir.join("config/kitabu.yml")).with_indifferent_access
  end
end
