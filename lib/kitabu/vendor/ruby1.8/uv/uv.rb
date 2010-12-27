require 'fileutils'
require 'uv/render_processor.rb'


module Uv

   def Uv.path
      result = []
      result << File.join(File.dirname(__FILE__), ".." )   
   end
   
   def Uv.copy_files output, output_dir
      Uv.path.each do |dir|
         dir_name = File.join( dir, "render", output, "files" )
         FileUtils.cp_r( Dir.glob(File.join( dir_name, "." )), output_dir ) if File.exists?( dir_name )
      end
   end

   def Uv.init_syntaxes
      @syntaxes = {}
      Dir.glob( File.join(File.dirname(__FILE__), 'syntax', '*.syntax') ).each do |f| 
         @syntaxes[File.basename(f, '.syntax')] = Textpow::SyntaxNode.load( f )
      end
   end

   def Uv.syntaxes
      Dir.glob( File.join(File.dirname(__FILE__), 'syntax', '*.syntax') ).collect do |f| 
         File.basename(f, '.syntax')
      end
   end
   
   def Uv.themes
      Dir.glob( File.join(File.dirname(__FILE__), 'render', 'xhtml', 'files', 'css', '*.css') ).collect do |f| 
         File.basename(f, '.css')
      end
   end

   def Uv.syntax_for_file file_name
      init_syntaxes unless @syntaxes
      first_line = ""
      File.open( file_name, 'r' ) { |f|
         while (first_line = f.readline).strip.size == 0; end
      }
      result = []
      @syntaxes.each do |key, value|
         assigned = false
         if value.fileTypes
            value.fileTypes.each do |t|
               if t == File.basename( file_name ) || t == File.extname( file_name )[1..-1]
                  result << [key, value] 
                  assigned = true
                  break
               end
            end
         end
         unless assigned
            if value.firstLineMatch && value.firstLineMatch =~ first_line
               result << [key, value] 
            end
         end
      end
      result
   end
   
   def Uv.parse text, output = "xhtml", syntax_name = nil, line_numbers = false, render_style = "classic", headers = false
      init_syntaxes unless @syntaxes
      renderer = File.join( File.dirname(__FILE__), "render", output,"#{render_style}.render")
      raise( ArgumentError, "Output for #{output} is not yet implemented" ) unless File.exists?(renderer)
      css_class = render_style
      render_options = YAML.load( File.open(  renderer ) )
      render_processor = RenderProcessor.new( render_options, line_numbers, headers )
      @syntaxes[syntax_name].parse( text,  render_processor )
      render_processor.string
   end

   def Uv.debug text, syntax_name
      unless @syntaxes
         @syntaxes = {}
         Dir.glob( File.join(File.dirname(__FILE__), 'syntax', '*.syntax') ).each do |f| 
            @syntaxes[File.basename(f, '.syntax')] = Textpow::SyntaxNode.load( f )
         end
      end
      processor = Textpow::DebugProcessor.new

      @syntaxes[syntax_name].parse( text, processor )
   end

end