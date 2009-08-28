require "kitabu"

begin
  require Kitabu::Base.markdown_processor.downcase
rescue LoadError => e
  puts  "\n#{Kitabu::Base.markdown_processor} gem not found. NO MARKDOWN for you.\n" +
        "Install using `sudo gem install #{Kitabu::Base.markdown_processor}`.\n"
end

require File.dirname(__FILE__) + "/redcloth"
require File.dirname(__FILE__) + "/blackcloth"

begin
  require "uv"
rescue LoadError => e
  puts  "\nUltraviolet gem not found. NO SYNTAX HIGHLIGHT for you.\n" +
        "Install using `sudo gem install ultraviolet`.\n\n"
end

begin
  require "unicode"
rescue LoadError => e
  puts  "\nUnicode gem not found. NO TOC for you.\n" +
        "Install using `sudo gem install unicode`.\n\n"
end

begin
  require "colorize"
rescue LoadError => e
  puts  "\nColorize gem not found.\n" +
        "Install using `sudo gem install fnando-colorize -s http://gems.github.com`.\n\n"
end

# extend BlackCloth if module Helpers is defined
BlackCloth.__send__(:include, ::Helpers) if defined?(::Helpers)

task :default => "kitabu:auto"

namespace :kitabu do
  desc "Generate PDF from markup files"
  task :pdf => :html do
    Kitabu::Base.generate_pdf
    puts "Your PDF has been generated. Check it out the output directory!"
    sleep(1) && system("open #{Kitabu::Base.pdf_path}") if RUBY_PLATFORM =~ /darwin/ && ENV["AUTO_OPEN"] == "1"
  end

  desc "Generate HTML from markup files"
  task :html do
    Kitabu::Base.generate_html
  end

  desc "List all available syntaxes"
  task :syntaxes do
    puts Kitabu::Base.syntaxes.sort.join("\n")
  end

  desc "List all available themes"
  task :themes do
    puts Kitabu::Base.themes.sort.join("\n")
  end
  
  desc "List all titles and its permalinks"
  task :titles => :html do
    contents = File.new(Kitabu::Base.html_path).read
    output = ""
    
    contents.scan(/<h([1-6])(.*?)>(.*?)<\/h[1-6]>/sim) do
      level = $1.to_i - 1
      output << "-" * level
      output << " " if level > 0
      
      if level == 0
        output << Colorize.yellow($3.upcase, :style => :underscore)
      else
        output << $3
      end
      
      output << Colorize.green($2.to_s.gsub(/^.*?id=['"](.*?)['"].*?$/, ' #\1'))
      output << "\n"
    end
    
    puts output
  end
  
  task :watch => :auto

  desc "Watch changes and automatically generate html & pdf"
  task :auto do
    thread = Thread.new do
      latest_mtime = 0

      trap 'INT' do
        puts
        thread.exit
      end

      loop do
        files = Dir["./**/*"].reject {|p| p =~ /\.\/output/ }
        changes = []
        
        mtime = files.collect do |file| 
          mt = File.mtime(file).to_i
          changes << file if latest_mtime > 0 && mt > latest_mtime
          mt
        end.max

        if latest_mtime < mtime
          if changes.size > 0
            puts Colorize.yellow("\n\n#{changes.size} file(s) changed") + " - #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
            changes.each do |file| 
              puts "  - #{Colorize.blue(file, :options => :highlight)}"
            end unless latest_mtime == 0
          end
          latest_mtime = mtime
          
          Kitabu::Base.generate_html
          Kitabu::Base.generate_pdf
          puts Colorize.green("== PDF exported!")
          
          puts
        end

        sleep ENV["WAIT"] || 1
      end
    end

    thread.join
  end
end