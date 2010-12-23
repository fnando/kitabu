require "digest/md5"
require "eeepub"
require "erb"
require "notifier"
require "optparse"
require "ostruct"
require "rdoc/markup"
require "rdoc/markup/to_html"
require "RedCloth"
require "rexml/document"
require "rexml/streamlistener"
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

require "active_support/all"
require "nokogiri"

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
  autoload :Rearrange,  "kitabu/rearrange"
  autoload :Exporter,   "kitabu/exporter"
end
