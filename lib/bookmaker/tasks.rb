require "bookmaker"

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

namespace :book do
  desc "Generate PDF from markup files"
  task :pdf => :html do
    Bookmaker::Base.generate_pdf
    puts "Your PDF has been generated. Check it out the output directory!"
    sleep(1) && system("open #{Bookmaker::Base.pdf_path}") if RUBY_PLATFORM =~ /darwin/
  end

  desc "Generate HTML from markup files"
  task :html do
    Bookmaker::Base.generate_html
  end

  desc "List all available syntaxes"
  task :syntaxes do
    puts Bookmaker::Base.syntaxes.sort.join("\n")
  end

  desc "List all available themes"
  task :themes do
    puts Bookmaker::Base.themes.sort.join("\n")
  end

  desc "Watch changes and automatically generate html"
  task :watch do
    thread = Thread.new do
      latest_mtime = 0

      trap 'INT' do
        puts
        thread.exit
      end

      loop do
        files = Dir["text/**/*.textile"] + Dir["text/**/*.markdown"]
        changes = []
        
        mtime = files.collect do |file| 
          mt = File.mtime(file).to_i
          changes << file if latest_mtime > 0 && mt > latest_mtime
          mt
        end.max

        if latest_mtime < mtime
          puts "generating html - #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
          changes.each {|file| puts "  - #{file}" } unless latest_mtime == 0
          latest_mtime = mtime
          Bookmaker::Base.generate_html
        end

        sleep 5
      end
    end

    thread.join
  end
end