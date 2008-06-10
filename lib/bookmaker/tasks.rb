require "rubygems"
require "bookmaker"

begin
  require "ruby-debug"
rescue LoadError => e
  nil
end

begin
  require "discount"
rescue LoadError => e
  puts  "\nDiscount gem not found. NO MARKDOWN for you.\n" +
        "Install using `sudo gem install discount`.\n"
end

begin
  require "redcloth"
  require File.dirname(__FILE__) + "/blackcloth"
rescue LoadError => e
  puts  "\nRedCloth gem not found. NO TEXTILE for you.\n" +
        "Install using `sudo gem install redcloth`.\n"
end

begin
  require "uv" if RUBY_PLATFORM =~ /darwin/
rescue LoadError => e
  puts  "\nUltraviolet gem not found. NO SYNTAX HIGHLIGHT for you.\n" +
        "Install using `sudo gem install ultraviolet`.\n\n"
end

desc "Generate PDF from markup files"
task :pdf => :html do
  Bookmaker::Base.generate_pdf
  puts "Your PDF has been generated. Check it out the output directory!"
  sleep(2) && system("open #{Bookmaker::Base.pdf_path}") if RUBY_PLATFORM =~ /darwin/
end

desc "Generate HTML from markup files"
task :html do
  Bookmaker::Base.generate_html
end

desc "List all available syntaxes"
task :syntaxes do
  puts Bookmaker::Base.syntaxes.sort.join("\n")
end