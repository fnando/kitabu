# frozen_string_literal: true

require "active_support/all"
require "digest/md5"
require "tempfile"
require "epub"
require "erb"
require "nokogiri"
require "open3"
require "optparse"
require "ostruct"
require "pathname"
require "thor"
require "thor/group"
require "unicode/emoji"
require "yaml"
require "cgi"

require "redcarpet"
require "rouge"
require "rouge/plugins/redcarpet"

I18n.enforce_available_locales = false

Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

module Kitabu
  ROOT = Pathname.new("#{File.dirname(__FILE__)}/..")

  require "kitabu/extensions/string"
  require "kitabu/extensions/rouge"
  require "kitabu/errors"
  require "kitabu/version"
  require "kitabu/generator"
  require "kitabu/cli"
  require "kitabu/css"
  require "kitabu/markdown"
  require "kitabu/source_list"
  require "kitabu/exporter"
  require "kitabu/exporter/base"
  require "kitabu/exporter/html"
  require "kitabu/exporter/epub"
  require "kitabu/exporter/mobi"
  require "kitabu/exporter/pdf"
  require "kitabu/footnotes/base"
  require "kitabu/footnotes/html"
  require "kitabu/footnotes/pdf"
  require "kitabu/hook"
  require "kitabu/toc/html"
  require "kitabu/dependency"
  require "kitabu/stats"
  require "kitabu/helpers"
  require "kitabu/front_matter"
  require "kitabu/context"

  def self.config(root_dir = nil)
    root_dir ||= Pathname.new(Dir.pwd)
    path = root_dir.join("config/kitabu.yml")

    unless File.file?(path)
      raise "Invalid Kitabu directory; couldn't find config/kitabu.yml file."
    end

    content = File.read(path)
    erb = ERB.new(content).result
    YAML.safe_load(erb).with_indifferent_access
  end
end
