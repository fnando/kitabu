module Kitabu
  module Base
    DEFAULT_LAYOUT = 'boom'
    DEFAULT_THEME = 'eiffel'
    DEFAULT_SYNTAX = 'plain_text'
    GEM_ROOT = File.expand_path(File.dirname(__FILE__) + "/../../")
    
    extend self
    
    def html_path
      KITABU_ROOT + "/output/#{app_name}.html"
    end
    
    def pdf_path
      KITABU_ROOT + "/output/#{app_name}.pdf"
    end
    
    def template_path
      KITABU_ROOT + "/templates/layout.html"
    end
    
    def config_path
      KITABU_ROOT + "/config.yml"
    end
    
    def text_dir
      KITABU_ROOT + "/text"
    end
    
    def config
      @config ||= YAML::load_file(config_path)
    end
    
    def parse_layout(contents)
      template = File.new(template_path).read
      contents, toc = self.table_of_contents(contents)
      cfg = config.merge(:contents => contents, :toc => toc)
      env = OpenStruct.new(cfg)

      ERB.new(template).result env.instance_eval{ binding }
    end
    
    def table_of_contents(contents)
      return [contents, nil] unless defined?('Hpricot') && defined?('Unicode')
      
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
      REXML::Document.parse_stream(io, toc) rescue nil

      [contents, toc.to_s]
    end
    
    def generate_pdf
      IO.popen('prince %s -o %s' % [html_path, pdf_path])
    end
    
    def generate_html
      # parsed file holder
      contents = ""
      
      entries = Dir.entries(text_dir).sort.reject do |entry| 
        %w(. .. .svn .git).include?(entry) || (File.file?(entry) && entry !~ /\.(markdown|textile)$/)
      end
      
      $stdout << "\nNo markup files found!\n" if entries.empty?
      
      # first, get all chapters; then, get all parsed markdown
      # files from this chapter and group them into a <div class="chapter"> tag
      entries.each do |entry|
        # gets all parsed markdown files to wrap in a 
        # chapter element
        chapter = ""
        
        # entry can be a file outside chapter folder
        file = "#{text_dir}/#{entry}"
        
        if File.file?(file)
          markup_files = [file]
        else
          # merge all markdown and textile files into a single list
          markup_files =  Dir["#{text_dir}/#{entry}/**/*.markdown"] + 
                          Dir["#{text_dir}/#{entry}/**/*.textile"]
        end
        
        # no files, so skip it!
        next if markup_files.empty?
        
        markup_files.sort.each do |markup_file|
          # get the file contents
          markup_contents = File.read(markup_file)
          
          # instantiate a markup object
          begin
            if markup_file =~ /\.textile$/
              markup = BlackCloth.new(markup_contents)
            else
              markup = Discount.new(markup_contents)
            end
          rescue Exception => e
            $stdout << "\nSkipping #{markup_file} (#{e.message})"
            next
          end
          
          # convert the markup into html
          parsed_contents = markup.to_html
          
          if defined?(Uv)
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
                end
              
                Kitabu::Markup.syntax(code, syntax)
              end
            end
          end
          
          chapter << (parsed_contents + "\n\n")
        end
        
        contents << '<div class="chapter">%s</div>' % chapter
      end
      
      # create output directory if is missing
      FileUtils.mkdir(File.dirname(html_path)) unless File.exists?(File.dirname(html_path))
      
      # save html file
      File.open(html_path, 'w+') do |f|
        f << Kitabu::Base.parse_layout(contents)
      end
    end
    
    def app_name
      ENV['KITABU_NAME'] || 'kitabu'
    end
    
    def theme?(theme_name)
      themes.include?(theme_name)
    end
    
    def syntax?(syntax_name)
      syntaxes.include?(syntax_name)
    end
    
    def layout?(layout_name)
      layouts.include?(layout_name)
    end
    
    def default_theme
      DEFAULT_THEME
    end
    
    def default_syntax
      DEFAULT_SYNTAX
    end
    
    def default_layout
      DEFAULT_LAYOUT
    end
    
    def syntaxes
      Uv.syntaxes
    end
    
    def layouts
      @layouts ||= begin
        dir = File.join(GEM_ROOT, "templates/layouts")
        Dir.entries(dir).reject{|p| p =~ /^\.+$/ }.sort
      end
    end
    
    def themes
      @themes ||= begin
        filter = File.join(GEM_ROOT, "templates/themes/*.css")
        Dir[filter].collect{|path| File.basename(path).gsub(/\.css$/, '') }.sort
      end
    end
    
    def to_permalink(str)
      str = Unicode.normalize_KD(str).gsub(/[^\x00-\x7F]/n,'') 
      str = str.gsub(/[^-_\s\w]/, ' ').downcase.squeeze(' ').tr(' ', '-')
      str = str.gsub(/-+/, '-').gsub(/^-+/, '').gsub(/-+$/, '')
      str
    end
  end
end
