# encoding: utf-8
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

== Examples
  Using defaults.
    kitabu mybook

  Specify layout.
    kitabu -l boom mybook
    kitabu --layout boom mybook

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
            output "Invalid layout"
            exit 1
          end
          
          options[:layout] = layout
        end
        
        opts.on("-h", "--help", "Show help") do
          output KITABU_HELP
          exit 0
        end
        
        opts.on_tail("-v", "--version", "Show version") do
          output Kitabu::VERSION
          exit 0
        end
      end
      
      args = ARGV.dup
      other_args = opts.permute!
      
      unless other_args.any?
        output KITABU_HELP
        exit 0
      end
      
      path = File.expand_path(other_args.first)
      
      if File.exists?(path)
        output "Output path already exists"
        exit 1
      end
      
      opts.parse!(args)
      
      Kitabu::Templates.process!({
        :layout => options[:layout], 
        :theme => options[:theme], 
        :path => path
      })
    end
    
    def output(*args)
      puts *args
    end
  end
end
