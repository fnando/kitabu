require "kitabu"

begin
  require "discount"
rescue LoadError => e
  puts  "\nDiscount gem not found. NO MARKDOWN for you.\n" +
        "Install using `sudo gem install discount`.\n"
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
  require "hpricot"
rescue LoadError => e
  puts  "\nHpricot gem not found. NO TOC for you.\n" +
        "Install using `sudo gem install hpricot`.\n\n"
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
    doc = Hpricot(contents)
    counter = {}

    titles = (doc/"h2, h3, h4, h5, h6").collect do |node|
      title = node.inner_text
      permalink = Kitabu::Base.to_permalink(title)
      
      # initialize and increment counter
      counter[permalink] ||= 0
      counter[permalink] += 1
      
      # set a incremented permalink if more than one occurrence
      # is found
      permalink = "#{permalink}-#{counter[permalink]}" if counter[permalink] > 1
      
      [title, permalink]
    end
    
    titles.sort_by {|items| items.last }.each do |items|
      puts items.first
      puts %(##{items.last})
      puts
    end
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
          puts
        end

        sleep ENV["WAIT"] || 1
      end
    end

    thread.join
  end
end