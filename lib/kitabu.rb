require "active_support/all"
require "digest/md5"
require "eeepub"
require "erb"
require "logger"
require "nokogiri"
require "notifier"
require "open3"
require "optparse"
require "ostruct"
require "RedCloth"
require "tempfile"
require "thor"
require "thor/group"
require "watchr"
require "yaml"
require "cgi"

%w[pygments.rb coderay].each do |lib|
  begin
    require lib
  rescue LoadError => e
    next
  end
end

%w[maruku peg_markdown bluecloth redcarpet rdiscount].each do |lib|
  begin
    require lib
    break
  rescue LoadError => e
    next
  end
end

Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

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
  autoload :Dependency, "kitabu/dependency"

  def self.config(root_dir = nil)
    root_dir ||= Pathname.new(Dir.pwd)
    path = root_dir.join("config/kitabu.yml")

    raise "Invalid Kitabu directory; couldn't found config/kitabu.yml file." unless File.file?(path)
    content = File.read(path)
    erb = ERB.new(content).result
    YAML.load(erb).with_indifferent_access
  end

  def self.logger
    @logger ||= Logger.new(File.open("/tmp/kitabu.log", "a+"))
  end
end
