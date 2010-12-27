# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "kitabu/version"

Gem::Specification.new do |s|
  s.name        = "kitabu"
  s.version     = Kitabu::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nando Vieira"]
  s.email       = ["fnando.vieira@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/kitabu"
  s.summary     = "A framework that generates PDF and e-Pub from Markdown, Textile, and HTML files."
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activesupport",             "~> 3.0.3"
  s.add_dependency "nokogiri",                  "~> 1.4.4"
  s.add_dependency "RedCloth",                  "~> 4.2.3"
  s.add_dependency "rdiscount",                 "~> 1.6.5"
  s.add_dependency "i18n",                      "~> 0.5.0"
  s.add_dependency "thor",                      "~> 0.14.6"
  s.add_dependency "eeepub",                    "~> 0.6.1"
  s.add_dependency "watchr",                    "~> 0.7.0"
  s.add_dependency "notifier",                  "~> 0.1.2"
  s.add_development_dependency "rspec",         "~> 2.3.0"
  s.add_development_dependency "ZenTest",       "~> 4.4.1"
  s.add_development_dependency "test_notifier", "~> 0.3.6"
  s.add_development_dependency "ruby-debug19"
end
