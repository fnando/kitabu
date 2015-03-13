# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "kitabu/version"

Gem::Specification.new do |s|
  s.name                  = "kitabu"
  s.version               = Kitabu::Version::STRING
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = ">= 1.9"
  s.authors               = ["Nando Vieira"]
  s.email                 = ["fnando.vieira@gmail.com"]
  s.homepage              = "http://rubygems.org/gems/kitabu"
  s.summary               = "A framework that generates PDF and e-Pub from Markdown, Textile, and HTML files."
  s.description           = s.summary
  s.license               = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activesupport"
  s.add_dependency "nokogiri"
  s.add_dependency "i18n"
  s.add_dependency "thor"
  s.add_dependency "redcarpet"
  s.add_dependency "eeepub-with-cover-support"
  s.add_dependency "rouge"
  s.add_dependency "notifier"
  s.add_dependency "rubyzip"
  s.add_dependency "zip-zip"

  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry-meta"
  s.add_development_dependency "codeclimate-test-reporter"
end
