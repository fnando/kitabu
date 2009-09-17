module Kitabu
  module Syntax
    extend self
    
    def content_for(options)
      # retrieve the file source
      source_file = File.join(KITABU_ROOT, "code", options[:source_file].to_s)
      
      # shortcut to the code
      code = options[:code]
      
      if options[:source_file] && File.exists?(source_file)
        # Here's the thing: if the source file has been specified and the
        # correspondent file exists, process it!
        file = File.open(source_file, "r")
        
        if options[:from_line] && options[:to_line]
          # Check if there's a line range and if so, set the code to
          # the chosen lines
          from_line = options[:from_line].to_i - 1
          to_line = options[:to_line].to_i
          offset = to_line - from_line
          code = file.readlines.slice(from_line, offset).join
        elsif block_name = options[:block_name]
          # Check if there's a block name and retrieve it
          re = %r(# ?begin: ?\b#{block_name}\b ?(?:[^\r\n]+)?\r?\n(.*?)\r?\n([^\r\n]+)?# ?end: \b#{block_name}\b)sim
          file.read.gsub(re) { |block| code = $1 }
        else
          # As last resource, just read the whole file
          code = file.read
          code = code.gsub(/&lt;/, '<').gsub(/&gt;/, '>').gsub(/&amp;/, '&')
        end
      end
      
      # no code? set to default
      code ||= options[:code]
      
      # normalize indentation
      line = StringIO.new(code).readlines[0]

      if line =~ /^(\t+)/
        char = "\t"
        size = $1.length
      elsif line =~ /^( +)/
        char = " "
        size = $1.length
      end

      code.gsub! %r(^#{char}{#{size}}), "" if size.to_i > 0
      
      # remove all line stubs
      code.gsub! %r(^[\t ]*__$), ""
      code
    end
    
    def apply(code, syntax, processor)
      # get chosen theme or default
      theme = Kitabu::Base.config["theme"]
      theme = Kitabu::Base.default_theme unless Kitabu::Base.theme?(theme)
      
      # get default syntax if no syntax has been set yet
      syntax = Kitabu::Base.default_syntax if syntax.to_s =~ /^\s*$/ || !Kitabu::Base.syntax?(syntax)
      
      # replace ampersand for textile; this is added
      # by RedCloth
      code.gsub!(/x%x%/sm, "&") if processor == :textile
      
      # do replace PRE tags using the syntax and added classes
      code = Uv.parse(code, "xhtml", syntax, false, theme)
      code.gsub!(/<pre class="(.*?)"/sim, %(<pre class="\\1 #{syntax}"))
      code.gsub!(/<pre>/sim, %(<pre class="#{syntax} #{theme}"))
      
      code
    end
    
    def process(content, markup)
      if defined?(Uv)
        if markup.respond_to?(:syntax_blocks)
          # textile
          content = content.gsub(/@syntax:([0-9]+)/m) do |m|
            syntax, code = markup.syntax_blocks[$1.to_i]
            Kitabu::Syntax.apply(code, syntax, :textile)
          end
        else
          # markdown
          content = content.gsub /<pre><code>(.*?)<\/code><\/pre>/m do |block|
            code = $1.gsub(/&lt;/, '<').gsub(/&gt;/, '>').gsub(/&amp;/, '&')
            code_lines = StringIO.new(code).readlines
            syntax_settings = code_lines.first

            syntax = "plain_text"

            if syntax_settings =~ /syntax\(.*?\)\./
              code = code_lines.slice(1, code_lines.size).join

              # syntax
              m, syntax = *syntax_settings.match(/syntax\(([^ #]+).*?\)./)

              # file name
              m, source_file = *syntax_settings.match(/syntax\(.*?\)\. +(.*?)$/)

              # get line interval
              m, from_line, to_line = *syntax_settings.match(/syntax\(.*? ([0-9]+),([0-9]+)\)/)

              # get block name
              m, block_name = *syntax_settings.match(/syntax\(.*?#([0-9a-z_]+)\)/)

              code = Kitabu::Syntax.content_for({
                :code => code,
                :from_line => from_line,
                :to_line => to_line,
                :block_name => block_name,
                :source_file => source_file
              })
            end

            Kitabu::Syntax.apply(code, syntax, :markdown)
          end
        end
      end
    end
  end
end
