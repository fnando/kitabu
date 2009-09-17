require "rake"
require "jeweler"
require File.dirname(__FILE__) + "/lib/kitabu"

JEWEL = Jeweler::Tasks.new do |gem|
  gem.name = "kitabu"
  gem.version = Kitabu::VERSION
  gem.summary = "A framework for creating e-books from Markdown/Textile text markup using Ruby."
  gem.description = <<-TXT
A framework for creating e-books from Markdown/Textile text markup using Ruby. 
Using the Prince PDF generator, you'll be able to get high quality PDFs.
TXT
  
  gem.authors = ["Nando Vieira"]
  gem.email = "fnando.vieira@gmail.com"
  gem.homepage = "http://fnando.github.com/kitabu.html"
  
  gem.has_rdoc = false
  gem.files = %w(Rakefile kitabu.gemspec VERSION README.markdown) + Dir["{bin,lib,templates}/**/*"]
	gem.bindir = "bin"
	gem.executables = "kitabu"
end

desc "Generate gemspec, build and install the gem"
task :package do
  File.open("VERSION", "w+") {|f| f << Kitabu::VERSION.to_s }
  FileUtils.cp "VERSION", File.expand_path("~/Sites/github/glue-pages/views/version/_#{JEWEL.gemspec.name}.haml")
  
  Rake::Task["gemspec"].invoke
  Rake::Task["build"].invoke
  Rake::Task["install"].invoke
end
