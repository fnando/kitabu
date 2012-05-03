# -*- encoding: utf-8 -*-
module Kitabu
  class Cli < Thor
    FORMATS = %w[pdf html epub mobi txt]
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
    method_option :open, :type => :boolean, :desc => "Automatically open PDF (Mac OS X only)"
    method_option :overwrite, :type => :boolean, :desc => "Overwrite html file if already exported"

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

    desc "check", "Check if all external dependencies are installed"

    def check
      result = []

      result << {
        :description => "Prince XML: Converts HTML files into PDF files.",
        :installed => Kitabu::Dependency.prince?
      }

      result << {
        :description => "KindleGen: Converts ePub e-books into .mobi files.",
        :installed => Kitabu::Dependency.kindlegen?
      }

      result << {
        :description => "html2text: Converts HTML documents into plain text.",
        :installed => Kitabu::Dependency.html2text?
      }

      result << {
        :description => "pygments.rb: A generic syntax highlight. If installed, replaces CodeRay.",
        :installed => Kitabu::Dependency.pygments_rb?
      }

      result.each do |result|
        text = color(result[:name], :blue)
        text << "\n" << result[:description]
        text << "\n" << (result[:installed] ? color("Installed.", :green) : color("Not installed.", :red))
        text << "\n"

        say(text)
      end
    end

    desc "permalinks", "List title permalinks"

    def permalinks
      inside_ebook!

      html = Kitabu::Parser::HTML.new(root_dir).content
      toc = Kitabu::TOC::HTML.generate(html)

      toc.toc.each do |options|
        level = options[:level] - 1
        title = " #{options[:text]}: "
        permalink = "##{options[:permalink]}"

        text = "*" * level
        text << color(title, :blue)
        text << color(permalink, :yellow)
        say(text)
      end
    end

    desc "stats", "Display some stats about your e-book"
    def stats
      inside_ebook!
      stats = Kitabu::Stats.new(root_dir)

      say [
        "Chapters: #{stats.chapters}",
        "Words: #{stats.words}",
        "Images: #{stats.images}",
        "Links: #{stats.links}",
        "Footnotes: #{stats.footnotes}",
        "Code blocks: #{stats.code_blocks}"
      ].join("\n")
    end

    private
    def inside_ebook!
      unless File.exist?(config_path)
        raise Error, "You have to run this command from inside an e-book directory."
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

    def color(text, color)
      color? ? shell.set_color(text, color) : text
    end

    def color?
      shell.instance_of?(Thor::Shell::Color)
    end
  end
end
