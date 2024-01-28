# frozen_string_literal: true

module Kitabu
  class Exporter
    def self.default_i18n_load_path
      @default_i18n_load_path ||= I18n.load_path.dup.freeze
    end

    def self.load_translations(root_dir:)
      paths = default_i18n_load_path.dup
      paths += Dir[root_dir.join("config/locales/**/*.{yml,rb}").to_s]
      paths << File.expand_path(File.join(__dir__, "../../../templates/en.yml"))

      I18n.load_path = paths

      I18n.backend.reload!
      I18n.backend.eager_load!
    end

    class Base
      # The e-book directory.
      #
      attr_accessor :root_dir

      # Where the text files are stored.
      #
      attr_accessor :source

      def self.export(root_dir)
        Exporter.load_translations(root_dir:)
        new(root_dir).export
      end

      def initialize(root_dir)
        @root_dir = Pathname.new(root_dir)
        @source = root_dir.join("text")
      end

      def export
        FileUtils.mkdir_p(root_dir.join("output"))
      end

      def source_list
        @source_list ||= SourceList.new(root_dir)
      end

      # Return directory's basename.
      #
      def name
        File.basename(root_dir)
      end

      # Return the configuration file.
      #
      def config
        Kitabu.config(root_dir)
      end

      # Render a eRb template using +locals+ as data seed.
      #
      def render_template(template, locals = {})
        ERB.new(
          template,
          trim_mode: "%<>",
          eoutvar: "@_output"
        ).result(Context.create(locals))
      end

      def spawn_command(command)
        stdout_and_stderr, status = Open3.capture2e(*command)
      rescue Errno::ENOENT => error
        puts error.message
      else
        puts stdout_and_stderr unless status.success?
        status.success?
      end

      def ui
        @ui ||= Thor::Base.shell.new
      end

      def handle_error(error)
        ui.say "#{error.class}: #{error.message}", :red
        ui.say error.backtrace.join("\n"), :white
      end

      def copy_files(source, target)
        target = root_dir.join(target)
        FileUtils.mkdir_p root_dir.join(target)

        Dir[root_dir.join(source)].each do |path|
          FileUtils.cp path, target
        end
      end

      def copy_directory(source, target)
        return unless root_dir.join(source).directory?

        source = root_dir.join("#{source}/.")
        target = root_dir.join(target)

        FileUtils.mkdir_p target
        FileUtils.cp_r source, target, remove_destination: true
      end
    end
  end
end
