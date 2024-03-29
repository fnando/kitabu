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

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|r| require r }

p [
  :filter_env,
  {
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
    calibre: false,
    prince: false,
    osx: false,
    linux: false
  )

  cleaner = proc do
    [
      TMPDIR,
      SPECDIR.join("support/mybook/output")
    ].each do |i|
      FileUtils.rm_rf(i)
    end

    Dir.chdir File.expand_path("..", __dir__)
  end

  config.before(&cleaner)
  config.after(&cleaner)
  config.before { FileUtils.mkdir_p(TMPDIR) }

  config.before do
    I18n.load_path = Dir["#{__dir__}/../lib/kitabu/locales/*.yml"]
    Kitabu::Markdown.hooks.clear
    Kitabu::Markdown.setup_default_hooks
    Kitabu::Markdown.processor.renderer.heading_counter.clear
  end
end
