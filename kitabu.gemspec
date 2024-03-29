# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require "kitabu/version"

Gem::Specification.new do |s|
  s.name                  = "kitabu"
  s.version               = Kitabu::Version::STRING
  s.platform              = Gem::Platform::RUBY
  s.authors               = ["Nando Vieira"]
  s.email                 = ["me@fnando.com"]
  s.homepage              = "http://rubygems.org/gems/kitabu"
  s.summary               = "A framework for creating e-books from Markdown " \
                            "using Ruby. Using the Prince PDF generator, " \
                            "you'll be able to get high quality PDFs. Also " \
                            "supports EPUB, Mobi, Text and HTML generation."
  s.description           = s.summary
  s.license               = "MIT"
  s.required_ruby_version = ">= 3.2"
  s.metadata = {"rubygems_mfa_required" => "true"}

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map do |f|
    File.basename(f)
  end
  s.require_paths = ["lib"]

  s.add_dependency "activesupport"
  s.add_dependency "epub-rb"
  s.add_dependency "i18n"
  s.add_dependency "nokogiri"
  s.add_dependency "redcarpet"
  s.add_dependency "rouge"
  s.add_dependency "rubyzip"
  s.add_dependency "thor"
  s.add_dependency "unicode-emoji"

  s.add_development_dependency "pry-meta"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "rubocop-fnando"
  s.add_development_dependency "simplecov"
end
