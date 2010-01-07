require "rake"
require "jeweler"
require File.dirname(__FILE__) + "/lib/kitabu"

JEWEL = Jeweler::Tasks.new do |gem|
  gem.name = "kitabu"
  gem.version = ENV["VERSION"] || Kitabu::VERSION
  gem.summary = "A framework for creating e-books from Markdown/Textile text markup using Ruby."
  gem.description = <<-TXT
A framework for creating e-books from Markdown/Textile text markup using Ruby.
With Prince PDF generator, you'll be able to get high quality PDFs.
TXT

  gem.authors = ["Nando Vieira"]
  gem.email = "fnando.vieira@gmail.com"
  gem.homepage = "http://fnando.github.com/public/kitabu.html"

  gem.has_rdoc = false
  gem.files = %w(Rakefile kitabu.gemspec VERSION README.markdown) + Dir["{bin,templates,lib}/**/*"]
	gem.bindir = "bin"
	gem.executables = "kitabu"

	gem.add_dependency "activesupport", ">=2.3"
end

desc "Build and install the gem"
task :package => :build_gem do
  FileUtils.cp "VERSION", File.expand_path("~/Sites/github/fnando.github.com/views/version/_#{JEWEL.gemspec.name}.haml")
end

desc "Generate gemspec and build gem"
task :build_gem do
  File.open("VERSION", "w+") {|f| f << (ENV["VERSION"] || Kitabu::VERSION.to_s) }

  Rake::Task["gemspec"].invoke
  Rake::Task["build"].invoke
end
