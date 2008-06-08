require "rubygems"
require "discount"
require "bookmaker"

begin
  require "ruby-debug"
rescue LoadError => e
  nil
end


begin
  require "uv" if RUBY_PLATFORM =~ /darwin/
rescue LoadError => e
  puts  "Ultraviolet gem not found.\n" +
        "Install using `sudo gem install ultraviolet`.\n" + 
        "Check http://bookmaker.rubyforge.org/ for additional info.\n"
end

desc "Generate PDF from markdown files"
task :pdf => :html do
  Bookmaker::Base.generate_pdf
  puts "Your PDF has been generated. Check it out the output directory!"
  sleep(2) && system("open #{Bookmaker::Base.pdf_path}") if RUBY_PLATFORM =~ /darwin/
end

desc "Generate HTML from markdown files"
task :html do
  Bookmaker::Base.generate_html
  puts "All markdown files converted to HTML"
end

desc "List all available syntaxes"
task :syntaxes do
  puts Bookmaker::Base.syntaxes.sort.join("\n")
end