module Kitabu
  module Base
    DEFAULT_LAYOUT = "boom"
    DEFAULT_THEME = "eiffel"
    DEFAULT_SYNTAX = "plain_text"
    DEFAULT_MARKDOWN_PROCESSOR = "rdiscount"
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
    
    # Load the configuration file
    def config
      @config = YAML::load_file(config_path)
    end
    
    # Parse erb template propagating the configuration file
    # and adding more variables
    def parse_layout(contents)
      template = File.new(template_path).read
      contents, toc = self.table_of_contents(contents)
      cfg = config.merge(:contents => contents, :toc => toc)
      env = OpenStruct.new(cfg)

      ERB.new(template).result env.instance_eval{ binding }
    end
    
    def table_of_contents(contents)
      return [contents, nil] unless defined?("Hpricot")
      
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
      IO.popen("prince %s -o %s" % [html_path, pdf_path]).close
    end
    
    def generate_html
      # parsed file holder
      contents = ""
      
      # skip some patterns
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
              markup.no_span_caps = true
            else
              markup = markdown_processor_class.new(markup_contents)
            end
          rescue Exception => e
            $stdout << "\nSkipping #{markup_file} (#{e.message})"
            next
          end
          
          # convert the markup into html
          parsed_contents = markup.to_html
          
          # process syntax highlight
          parsed_contents = Kitabu::Syntax.process(parsed_contents, markup)
          
          # add final content to the chapter buffer
          chapter << (parsed_contents + "\n\n")
        end
        
        # wrap chapter in div, so i can be styled accordingly
        contents << %[<div class="chapter">%s</div>] % chapter
      end
      
      # create output directory if is missing
      FileUtils.mkdir(File.dirname(html_path)) unless File.exists?(File.dirname(html_path))
      
      # save html file
      File.open(html_path, "w+") do |f|
        f << Kitabu::Base.parse_layout(contents)
      end
    end
    
    def app_name
      ENV["KITABU_NAME"] || "kitabu"
    end
    
    # Check if the specified theme is available
    def theme?(theme_name)
      themes.include?(theme_name)
    end
    
    # Check if the specified syntax is available
    def syntax?(syntax_name)
      syntaxes.include?(syntax_name)
    end
    
    # Check if the specified layout is available
    def layout?(layout_name)
      layouts.include?(layout_name)
    end
    
    # Wrap the default theme constant in a method
    def default_theme
      DEFAULT_THEME
    end
    
    # Wrap the default syntax constant in a method
    def default_syntax
      DEFAULT_SYNTAX
    end
    
    # Wrap the default layout constant in a method
    def default_layout
      DEFAULT_LAYOUT
    end
    
    # Wrap the default Markdown constant in a method
    def default_markdown_processor
      DEFAULT_MARKDOWN_PROCESSOR
    end
    
    # Return the current Markdown class
    def markdown_processor
      config["markdown"] || default_markdown_processor
    end
    
    # Select Markdown processor based on string
    def markdown_processor_class
      case markdown_processor
        when "maruku" then Maruku
        when "bluecloth" then BlueCloth
        when "peg_markdown" then PEGMarkdown
        else RDiscount
      end
    end
    
    # Return a list will all available syntaxes
    def syntaxes
      Uv.syntaxes
    end
    
    # Return a list with all available layouts
    def layouts
      @layouts ||= begin
        dir = File.join(GEM_ROOT, "templates/layouts")
        Dir.entries(dir).reject{|p| p =~ /^\.+$/ }.sort
      end
    end
    
    # Return a list with all available themes
    def themes
      @themes ||= begin
        filter = File.join(GEM_ROOT, "templates/themes/*.css")
        Dir[filter].collect{|path| File.basename(path).gsub(/\.css$/, '') }.sort
      end
    end
    
    # Normalize string by replacing accented characters
    # for its equivalent.
    def to_permalink(str)
      str = ActiveSupport::Multibyte::Chars.new(str)
      str = str.normalize(:kd).gsub(/[^\x00-\x7F]/,'').to_s
      str.gsub!(/[^-\w\d]+/sim, "-")
      str.gsub!(/-+/sm, "-")
      str.gsub!(/^-?(.*?)-?$/, '\1')
      str.downcase!
      str
    end
  end
end
