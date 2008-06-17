require 'bookmaker'

class BookmakerGenerator < RubiGen::Base

  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  default_options :theme => Bookmaker::Base.default_theme,
    :layout => Bookmaker::Base.default_layout
  attr_reader :theme, :layout

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = File.expand_path(args.shift)
    @name = base_name
    extract_options
  end

  def manifest
    record do |m|
      m.directory ''
      BASEDIRS.each { |path| m.directory path }
      
      m.template "Rakefile", "Rakefile"
      m.template "user.css", "templates/user.css"
      m.template "layouts/#{@layout}/layout.css", "templates/layout.css"
      m.template "layouts/#{@layout}/layout.html", "templates/layout.html"
      m.template "css/#{@theme}.css", "templates/syntax.css"
      m.template "config.yml", "config.yml", :assigns => {:theme => @theme}
    end
  end

  protected
    def banner
      <<-EOS
The 'bookmaker' command creates a new book with a default
directory structure at the path you specify.

USAGE: #{spec.name} /path/to/your/book [options]
EOS
    end

    def add_options!(opts)
      opts.separator ''
      opts.separator 'Options:'
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
      opts.on("--layout=LAYOUT_NAME", String,
        "Define the book layout (#{Bookmaker::Base.layouts.join('|')})",
        "Default: #{Bookmaker::Base.default_layout}") { |x| options[:layout] = x }
      opts.on("--theme=THEME_NAME", String,
        "Define the syntax highlight theme (#{Bookmaker::Base.themes.join('|')})",
        "Default: #{Bookmaker::Base.default_theme}") { |x| options[:theme] = x } if RUBY_PLATFORM =~ /darwin/
    end

    def extract_options
      @theme = options[:theme]
      @layout = options[:layout]
    end

    BASEDIRS = %w(
      templates
      text
      output
      images
      code
    )
end