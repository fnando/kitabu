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
require "tempfile"
require "pathname"
require "thor"
require "thor/group"
require "yaml"
require "cgi"

require "redcarpet"
require "rouge"
require "rouge/plugins/redcarpet"

I18n.enforce_available_locales = false

Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

module Kitabu
  ROOT = Pathname.new(File.dirname(__FILE__) + "/..")

  require "kitabu/extensions/string"
  require "kitabu/extensions/rouge"
  require "kitabu/errors"
  require "kitabu/version"
  require "kitabu/generator"
  require "kitabu/toc"
  require "kitabu/cli"
  require "kitabu/markdown"
  require "kitabu/parser"
  require "kitabu/exporter"
  require "kitabu/stream"
  require "kitabu/dependency"
  require "kitabu/stats"

  def self.config(root_dir = nil)
    root_dir ||= Pathname.new(Dir.pwd)
    path = root_dir.join("config/kitabu.yml")

    raise "Invalid Kitabu directory; couldn't found config/kitabu.yml file." unless File.file?(path)
    content = File.read(path)
    erb = ERB.new(content).result
    YAML.load(erb).with_indifferent_access
  end

  def self.logger
    @logger ||= Logger.new(File.open("/tmp/kitabu.log", "a"))
  end
end
