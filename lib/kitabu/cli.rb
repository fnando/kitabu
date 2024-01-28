# frozen_string_literal: true

module Kitabu
  class Cli < Thor
    FORMATS = %w[pdf html epub mobi].freeze
    check_unknown_options!

    def self.exit_on_failure?
      true
    end

    def initialize(args = [], options = {}, config = {})
      has_no_args = (
        config[:current_task] ||
        config[:current_command]
      ).name == "new" && args.empty?

      if has_no_args
        raise Error,
              "The e-Book path is required. For details run: kitabu help new"
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
    option :only, type: :string,
                  desc: "Can be one of: #{FORMATS.join(', ')}"
    option :open, type: :boolean,
                  desc: "Automatically open PDF (Preview.app for " \
                        "Mac OS X and xdg-open for Linux)"
    def export
      if options[:only] && !FORMATS.include?(options[:only])
        raise Error,
              "The --only option need to be one of: #{FORMATS.join(', ')}"
      end

      inside_ebook!

      Kitabu::Exporter.run(root_dir, options)
    end

    desc "version", "Prints the Kitabu's version information"
    map %w[-v --version] => :version

    def version
      say "Kitabu version #{Version::STRING}"
    end

    desc "check", "Check if all external dependencies are installed"

    def check
      result = []

      result << {
        description: "Prince XML: Converts HTML files into PDF files.",
        installed: Kitabu::Dependency.prince?
      }

      result << {
        description: "Calibre's ebook-convert: Converts ePub e-books into " \
                     ".mobi files.",
        installed: Kitabu::Dependency.calibre?
      }

      result.each do |info|
        state = if info[:installed]
                  color("Installed.", :green)
                else
                  color("Not installed.", :red)
                end

        text = color(info[:name], :blue)
        text << "\n" << info[:description]
        text << "\n" << state
        text << "\n"

        say(text)
      end
    end

    desc "permalinks", "List title permalinks"

    def permalinks
      inside_ebook!

      exporter = Kitabu::Exporter::HTML.new(root_dir)
      exporter.export
      navigation = ::Epub::Navigation.extract(
        [root_dir.join("output/#{exporter.name}.html")],
        root_dir: root_dir.join("output")
      )

      renderer = lambda do |hierarchy, level = 0|
        hierarchy.each do |entry|
          title = " #{entry.title}: "

          if entry.link != "#"
            text = "*" * level
            text << color(title, :blue)
            text << color(entry.link, :yellow)
            say(text)
          end

          renderer.call(entry.navigation, level + 1) if entry.navigation.any?
        end
      end

      renderer.call(navigation)
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

    no_commands do
      def inside_ebook!
        return if File.exist?(config_path)

        raise Error,
              "You have to run this command from inside an e-book directory."
      end

      def config
        YAML.load_file(config_path).with_indifferent_access
      end

      def config_path
        root_dir.join("config/kitabu.yml")
      end

      def root_dir
        @root_dir ||= Pathname.new(Dir.pwd)
      end

      def color(text, color)
        color? ? shell.set_color(text, color) : text
      end

      def color?
        shell.instance_of?(Thor::Shell::Color)
      end
    end
  end
end
