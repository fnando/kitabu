module Kitabu
  VERSION = "0.3.0"
  
  module Markup
    def self.content_for(options)
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
    
    def self.syntax(code, syntax='plain_text')
      # get chosen theme
      theme = Kitabu::Base.config['theme']
      theme = Kitabu::Base.default_theme unless Kitabu::Base.theme?(theme)
      
      # get syntax
      syntax = Kitabu::Base.default_syntax unless Kitabu::Base.syntax?(syntax)
      
      Uv.parse(code, "xhtml", syntax, false, theme)
    end
  end
  
  module Base
    DEFAULT_LAYOUT = 'boom'
    DEFAULT_THEME = 'eiffel'
    DEFAULT_SYNTAX = 'plain_text'
    GEM_ROOT = File.expand_path(File.dirname(__FILE__) + "/../../")
    
    def self.html_path
      KITABU_ROOT + "/output/#{app_name}.html"
    end
    
    def self.pdf_path
      KITABU_ROOT + "/output/#{app_name}.pdf"
    end
    
    def self.template_path
      KITABU_ROOT + "/templates/layout.html"
    end
    
    def self.config_path
      KITABU_ROOT + "/config.yml"
    end
    
    def self.text_dir
      KITABU_ROOT + "/text"
    end
    
    def self.config
      @config ||= YAML::load_file(config_path)
    end
    
    def self.parse_layout(contents)
      template = File.new(template_path).read
      contents, toc = self.table_of_contents(contents)
      cfg = config.merge(:contents => contents, :toc => toc)
      env = OpenStruct.new(cfg)

      ERB.new(template).result env.instance_eval{binding}
    end
    
    def self.table_of_contents(contents)
      return [contents, nil] unless Object.const_defined?('Hpricot') && Object.const_defined?('Unicode')
      
      doc = Hpricot(contents)
      counter = {}

      (doc/"h2, h3, h4, h5, h6").each do |node|
        title = node.inner_text
        permalink = Kitabu::Base.to_permalink(title)
        
        # initialize and increment counter
        counter[permalink] ||= 0
        counter[permalink] += 1
        
        # set a incremented permalink if more than one occurrence
        # is found
        permalink = "#{permalink}-#{counter[permalink]}" if counter[permalink] > 1
        
        node.set_attribute(:id, permalink)
      end
      
      contents = doc.to_html
      io = StringIO.new(contents)
      toc = Toc.new
      REXML::Document.parse_stream(io, toc)

      [contents, toc.to_s]
    end
    
    def self.generate_pdf
      IO.popen('prince %s -o %s' % [html_path, pdf_path])
    end
    
    def self.generate_html
      # all parsed markdown file holder
      contents = ""
      
      # first, get all chapters; then, get all parsed markdown
      # files from this chapter and group them into a <div class="chapter"> tag
      Dir.entries(text_dir).sort.each do |dirname|
        # ignore files and some directories
        next if %w(. .. .svn .git).include?(dirname) || File.file?(text_dir + "/#{dirname}")
        
        # gets all parsed markdown files to wrap in a 
        # chapter element
        chapter = ""
        
        # merge all markdown and textile files into a single list
        markup_files = Dir["#{text_dir}/#{dirname}/**/*.markdown"] + Dir["#{text_dir}/#{dirname}/**/*.textile"]
        
        # no files, so skip it!
        next if markup_files.empty?
        
        markup_files.sort.each do |markup_file|
          # get the file contents
          markup_contents = File.new(markup_file).read
          
          # instantiate a markup object
          begin
            if markup_file =~ /\.textile$/
              markup = BlackCloth.new(markup_contents)
            else
              markup = Discount.new(markup_contents)
            end
          rescue Exception => e
            puts "Skipping #{markup_file} (#{e.message})"
            next
          end
          
          # convert the markup into html
          parsed_contents = markup.to_html
          
          if Object.const_defined?('Uv')
            if markup.respond_to?(:syntax_blocks)
              # textile
              parsed_contents.gsub!(/@syntax:([0-9]+)/m) do |m|
                syntax, code = markup.syntax_blocks[$1.to_i]
                Kitabu::Markup.syntax(code, syntax)
              end
            else
              # markdown
              parsed_contents.gsub! /<pre><code>(.*?)<\/code><\/pre>/m do |block|
                code = $1.gsub(/&lt;/, '<').gsub(/&gt;/, '>').gsub(/&amp;/, '&')
                code_lines = StringIO.new(code).readlines
                syntax_settings = code_lines.first
                
                syntax = 'plain_text'
                
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
                  
                  code = Kitabu::Markup.content_for({
                    :code => code,
                    :from_line => from_line,
                    :to_line => to_line,
                    :block_name => block_name,
                    :source_file => source_file
                  })
                  
                  Kitabu::Markup.syntax(code, syntax)
                end
              end
            end
          end
          
          chapter << (parsed_contents + "\n\n")
        end
        
        contents << '<div class="chapter">%s</div>' % chapter
      end
      
      # create output directory if is missing
      FileUtils.mkdir(File.dirname(html_path))
      
      # save html file
      File.open(html_path, 'w+') do |f|
        f << Kitabu::Base.parse_layout(contents)
      end
    end
    
    def self.app_name
      ENV['KITABU_NAME'] || 'kitabu'
    end
    
    def self.theme?(theme_name)
      themes.include?(theme_name)
    end
    
    def self.syntax?(syntax_name)
      syntaxes.include?(syntax_name)
    end
    
    def self.layout?(layout_name)
      layouts.include?(layout_name)
    end
    
    def self.default_theme
      DEFAULT_THEME
    end
    
    def self.default_syntax
      DEFAULT_SYNTAX
    end
    
    def self.default_layout
      DEFAULT_LAYOUT
    end
    
    def self.syntaxes
      Uv.syntaxes
    end
    
    def self.layouts
      @layouts ||= begin
        dir = File.join(GEM_ROOT, "templates/layouts")
        Dir.entries(dir).reject{|p| p =~ /^\.+$/ }.sort
      end
    end
    
    def self.themes
      @themes ||= begin
        filter = File.join(GEM_ROOT, "templates/themes/*.css")
        Dir[filter].collect{|path| File.basename(path).gsub(/\.css$/, '') }.sort
      end
    end
    
    def self.to_permalink(str)
      str = Unicode.normalize_KD(str).gsub(/[^\x00-\x7F]/n,'') 
      str = str.gsub(/[^-_\s\w]/, ' ').downcase.squeeze(' ').tr(' ', '-')
      str = str.gsub(/-+/, '-').gsub(/^-+/, '').gsub(/-+$/, '')
      str
    end
  end
  
  class Toc
    include REXML::StreamListener

    def initialize
      @toc = ""
      @previous_level = 0
      @tag = nil
      @stack = []
    end

    def header?(tag=nil)
      tag ||= @tag_name
      return false unless tag.to_s =~ /h[2-6]/
      @tag_name = tag
      return true
    end

    def in_header?
      @in_header
    end

    def tag_start(name, attrs)
      @tag_name = name
      return unless header?(name)
      @in_header = true
      @current_level = name.gsub!(/[^2-6]/, '').to_i
      @stack << @current_level
      @id = attrs["id"]

      @toc << %(<ul class="level#{@current_level}">) if @current_level > @previous_level
      @toc << %(</li></ul>) * (@previous_level - @current_level) if @current_level < @previous_level
      @toc << %(</li>) if @current_level <= @previous_level
      @toc << %(<li>)
    end

    def tag_end(name)
      return unless header?(name)
      @in_header = false
      @previous_level = @current_level
    end

    def text(str)
      return unless in_header?
      @toc << %(<a href="##{@id}"><span>#{str}</span></a>)
    end

    def method_missing(*args)
    end

    def to_s
      @toc + (%(</li></ul>) * (@stack.last - 1))
    rescue
      ""
    end
  end
end