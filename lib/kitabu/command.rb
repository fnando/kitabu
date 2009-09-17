KITABU_HELP = <<-TXT
The 'kitabu' command creates a new book with a default
directory structure at the path you specify.

== Usage 
  kitabu [options] path

  For help use: kitabu -h

== Options
  -h, --help          Displays help message
  -v, --version       Display the version, then exit
  -l, --layout        Specify which layout to use
  -t, --theme         Specify which theme to use

== Examples
  Using defaults.
    kitabu mybook

  Specify layout.
    kitabu -l boom mybook
    kitabu --layout boom mybook

  Specify theme.
    kitabu -t eiffel mybook
    kitabu --theme eiffel mybook

== Author
  Nando Vieira
  http://simplesideias.com.br 

== Copyright
  Copyright (c) 2008-2009 Nando Vieira.
  Licensed under the MIT License: http://www.opensource.org/licenses/mit-license.php
TXT

module Kitabu
  module Command
    extend self
    
    def run!
      options = {}
      
      opts = OptionParser.new do |opts|
        opts.banner = "The 'kitabu' command creates a new book with a default\ndirectory structure at the path you specify."
        
        opts.separator ""
        opts.separator "Options:"
        
        opts.on("-l", "--layout LAYOUT", "Specify which layout to use.", "Available: #{Kitabu::Base.layouts.join(', ')}") do |layout|
          if layout && !Kitabu::Base.layout?(layout)
            puts "Invalid layout"
            exit(1)
          end
          
          options[:layout] = layout
        end
        
        opts.on("-t", "--theme THEME", "Specify which syntax highlight theme to use.", "Available: #{Kitabu::Base.themes.join(', ')}") do |theme|
          if theme && !Kitabu::Base.theme?(theme)
            puts "Invalid theme"
            exit(1)
          end
          
          options[:theme] = theme
        end
        
        opts.on("-h", "--help", "Show help") do
          puts KITABU_HELP
          exit
        end
        
        opts.on_tail("-v", "--version", "Show version") do
          puts Kitabu::VERSION
          exit
        end
      end
      
      args = ARGV.dup
      other_args = opts.permute!
      
      unless other_args.any?
        puts KITABU_HELP
        exit
      end
      
      path = File.expand_path(other_args.first)
      
      if File.exists?(path)
        puts "Output path already exists"
        exit(1)
      end
      
      opts.parse!(args)
      
      Kitabu::Templates.process!({
        :layout => options[:layout], 
        :theme => options[:theme], 
        :path => path
      })
    end
  end
end
