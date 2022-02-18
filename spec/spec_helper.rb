# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "spec"
end

require "bundler/setup"

require "kitabu"
require "pathname"

SPECDIR = Pathname.new(File.dirname(__FILE__))
TMPDIR = SPECDIR.join("tmp")

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each {|r| require r }

p [
  :filter_env,
  {
    html2text: Kitabu::Dependency.html2text?,
    calibre: Kitabu::Dependency.calibre?,
    prince: Kitabu::Dependency.prince?,
    macos: Kitabu::Dependency.macos?,
    linux: Kitabu::Dependency.linux?
  }
]

# Disable the bundle install command.
# TODO: Figure out the best way of doing it so.
module Kitabu
  class Generator < Thor::Group
    def bundle_install
    end
  end
end

RSpec.configure do |config|
  config.include(SpecHelper)
  config.include(Matchers)

  config.filter_run_excluding(
    html2text: false,
    calibre: false,
    prince: false,
    osx: false,
    linux: false
  )

  cleaner = proc do
    [TMPDIR].each do |i|
      FileUtils.rm_rf(i) if File.exist?(i)
    end

    Dir.chdir File.expand_path("..", __dir__)
  end

  config.before(&cleaner)
  config.after(&cleaner)
  config.before { FileUtils.mkdir_p(TMPDIR) }
end
