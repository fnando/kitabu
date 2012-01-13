# -*- encoding: utf-8 -*-
module Kitabu
  class Cli < Thor
    FORMATS = %w[pdf html epub mobi]
    check_unknown_options!

    def self.exit_on_failure?
      true
    end

    def initialize(args = [], options = {}, config = {})
      if config[:current_task].name == "new" && args.empty?
        raise Error, "The e-Book path is required. For details run: kitabu help new"
      end

      super
    end

    desc "new EBOOK_PATH", "Generate a new e-book structure"

    def new(path)
      generator = Generator.new
      generator.destination_root = path
      generator.invoke_all
    end

    desc "export [OPTIONS]", "Export e-book"
    method_option :only, :type => :string, :desc => "Can be one of: #{FORMATS.join(", ")}"
    method_option :auto, :type => :boolean, :desc => "Watch changes and automatically export files"
    method_option :open, :type => :boolean, :desc => "Automatically open PDF (Mac OS X only)"

    def export
      if options[:only] && !FORMATS.include?(options[:only])
        raise Error, "The --only option need to be one of: #{FORMATS.join(", ")}"
      end

      inside_ebook!

      Kitabu::Exporter.run(root_dir, options)
    end

    desc "version", "Prints the Kitabu's version information"
    map %w(-v --version) => :version

    def version
      say "Kitabu version #{Version::STRING}"
    end

    desc "permalinks", "List title permalinks"

    def permalinks
      html = Kitabu::Parser::Html.new(root_dir).content
      toc = Kitabu::Toc.generate(html)

      color_support = shell.instance_of?(Thor::Shell::Color)

      toc.toc.each do |options|
        level = options[:level] - 1
        title = " #{options[:text]}: "
        permalink = "##{options[:permalink]}"

        text = "*" * level
        text << (color_support ? shell.set_color(title, :blue) : title)
        text <<  (color_support ? shell.set_color(permalink, :yellow) : permalink)
        say(text)
      end
    end

    private
    def inside_ebook!
      unless File.exist?(config_path)
        raise Error, "You can't export files when you're outside an e-book directory"
      end
    end

    def config
      YAML.load_file(config_path).with_indifferent_access
    end

    def config_path
      root_dir.join("config/kitabu.yml")
    end

    def root_dir
      @root ||= Pathname.new(Dir.pwd)
    end
  end
end
