module Kitabu
  module Markup
    extend self
    
    def content_for(options)
      source_file = File.join(KITABU_ROOT, 'code', options[:source_file].to_s)
      code = options[:code]
      
      if options[:source_file] && File.exists?(source_file)
        file = File.new(source_file)
        
        if options[:from_line] && options[:to_line]
          from_line = options[:from_line].to_i - 1
          to_line = options[:to_line].to_i
          offset = to_line - from_line
          code = file.readlines.slice(from_line, offset).join
        elsif block_name = options[:block_name]
          re = %r(# ?begin: ?\b#{block_name}\b ?(?:[^\r\n]+)?\r?\n(.*?)\r?\n([^\r\n]+)?# ?end: \b#{block_name}\b)sim
          file.read.gsub(re) { |block| code = $1 }
        else
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
      
      # return
      code
    end
    
    def syntax(code, syntax, processor)
      # get chosen theme
      theme = Kitabu::Base.config['theme']
      theme = Kitabu::Base.default_theme unless Kitabu::Base.theme?(theme)
      
      syntax = "plain_text" if syntax.to_s =~ /^\s*$/
      
      # get syntax
      syntax = Kitabu::Base.default_syntax unless Kitabu::Base.syntax?(syntax)
      
      code.gsub!(/x%x%/sm, "&") if processor == :textile
      
      code = Uv.parse(code, "xhtml", syntax, false, theme)
      code.gsub!(/<pre class="(.*?)"/sim, %(<pre class="\\1 #{syntax}"))
      code.gsub!(/<pre>/sim, %(<pre class="#{syntax} #{theme}"))
      
      code
    end
  end
end