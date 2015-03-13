module Kitabu
  module Parser
    class HTML < Base
      # List of directories that should be skipped.
      #
      IGNORE_DIR = %w[. .. .svn]

      # Files that should be skipped.
      #
      IGNORE_FILES = /^(CHANGELOG|TOC)\..*?$/

      # List of recognized extensions.
      #
      EXTENSIONS = %w[md erb]

      class << self
        # The footnote index control. We have to manipulate footnotes
        # because each chapter starts from 1, so we have duplicated references.
        #
        attr_accessor :footnote_index
      end

      # Parse all files and save the parsed content
      # to <tt>output/book_name.html</tt>.
      #
      def parse
        reset_footnote_index!
        copy_images!
        export_stylesheets!

        File.open(root_dir.join("output/#{name}.html"), "w") do |file|
          file << parse_layout(content)
        end

        true
      rescue Exception
        false
      end

      def reset_footnote_index!
        self.class.footnote_index = 1
      end

      # Return all chapters wrapped in a <tt>div.chapter</tt> tag.
      #
      def content
        String.new.tap do |chapters|
          entries.each do |entry|
            files = chapter_files(entry)

            # no markup files, so skip to the next one!
            next if files.empty?

            chapters << %[<div class="chapter">#{render_chapter(files)}</div>]
          end
        end
      end

      # Return a list of all recognized files.
      #
      def entries
        Dir.entries(source).sort.inject([]) do |buffer, entry|
          buffer << source.join(entry) if valid_entry?(entry)
          buffer
        end
      end

      private
      def chapter_files(entry)
        # Chapters can be files outside a directory.
        if File.file?(entry)
          [entry]
        else
          Dir["#{entry}/**/*.{#{EXTENSIONS.join(",")}}"].sort
        end
      end

      # Check if path is a valid entry.
      # Files/directories that start with a dot or underscore will be skipped.
      #
      def valid_entry?(entry)
        entry !~ /^(\.|_)/ && (valid_directory?(entry) || valid_file?(entry))
      end

      # Check if path is a valid directory.
      #
      def valid_directory?(entry)
        File.directory?(source.join(entry)) && !IGNORE_DIR.include?(File.basename(entry))
      end

      # Check if path is a valid file.
      #
      def valid_file?(entry)
        ext = File.extname(entry).gsub(/\./, "").downcase
        File.file?(source.join(entry)) && EXTENSIONS.include?(ext) && entry !~ IGNORE_FILES
      end

      # Render +file+ considering its extension.
      #
      def render_file(file)
        if format(file) == :erb
          content = render_template(file, config)
        else
          content = File.read(file)
        end

        content = Kitabu::Markdown.render(content)
        render_footnotes(content)
      end

      def render_footnotes(content)
        html = Nokogiri::HTML(content)
        footnotes = html.css("p[id^='fn']")

        return content if footnotes.empty?

        reset_footnote_index! unless self.class.footnote_index

        footnotes.each do |fn|
          index = self.class.footnote_index
          actual_index = fn["id"].gsub(/[^\d]/, "")

          fn.set_attribute("id", "_fn#{index}")

          html.css("a[href='#fn#{actual_index}']").each do |link|
            link.set_attribute("href", "#_fn#{index}")
          end

          html.css("a[href='#fnr#{actual_index}']").each do |link|
            link.set_attribute("href", "#_fnr#{index}")
          end

          html.css("[id=fnr#{actual_index}]").each do |tag|
            tag.set_attribute("id", "_fnr#{index}")
          end

          self.class.footnote_index += 1
        end

        html.css("body").inner_html
      end

      def format(file)
        if File.extname(file) == '.erb'
          :erb
        else
          :markdown
        end
      end

      # Parse layout file, making available all configuration entries.
      #
      def parse_layout(html)
        toc = TOC::HTML.generate(html)
        locals = config.merge({
          content: toc.content,
          toc: toc.to_html,
          changelog: render_changelog
        })
        render_template(root_dir.join("templates/html/layout.erb"), locals)
      end

      # Render changelog file.
      # This file can be used to inform any book change.
      #
      def render_changelog
        changelog = Dir[root_dir.join("text/CHANGELOG.*")].first
        render_file(changelog) if changelog
      end

      # Render all +files+ from a given chapter.
      #
      def render_chapter(files)
        String.new.tap do |chapter|
          files.each do |file|
            chapter << render_file(file) << "\n\n"
          end
        end
      end

      # Copy images
      #
      def copy_images!
        FileUtils.cp_r root_dir.join("images/"), root_dir.join("output")
      end

      # Export all root stylesheets.
      #
      def export_stylesheets!
        files = Dir[root_dir.join("templates/styles/*.{scss,sass}").to_s]

        files.each do |file|
          _, file_name, syntax = *File.basename(file).match(/(.*?)\.(.*?)$/)
          engine = Sass::Engine.new(File.read(file), syntax: syntax.to_sym, style: :expanded, line_numbers: true)
          target = root_dir.join("output/styles", "#{file_name}.css")
          FileUtils.mkdir_p(File.dirname(target))
          File.open(target, "w") {|io| io << engine.render }
        end
      end
    end
  end
end
