# frozen_string_literal: false

module Kitabu
  class Exporter
    class HTML < Base
      class << self
        # The footnote index control. We have to manipulate footnotes
        # because each chapter starts from 1, so we have duplicated references.
        #
        attr_accessor :footnote_index
      end

      # Parse all files and save the parsed content
      # to <tt>output/book_name.html</tt>.
      #
      def export
        copy_images!
        copy_fonts!
        export_stylesheets!

        File.open(root_dir.join("output/#{name}.html"), "w") do |file|
          file << parse_layout(content)
        end

        true
      rescue StandardError => error
        handle_error(error)
        false
      end

      def reset_footnote_index!
        self.class.footnote_index = 1
      end

      # Return all chapters wrapped in a <tt>div.chapter</tt> tag.
      #
      def content
        "".tap do |content|
          source_list.each_chapter do |files|
            content << %[<div class="chapter">#{render_chapter(files)}</div>]
          end
        end
      end

      # Render +file+ considering its extension.
      #
      private def render_file(file)
        content = if format(file) == :erb
                    render_template(file, config)
                  else
                    File.read(file)
                  end

        Kitabu::Markdown.render(content)
      end

      private def format(file)
        if File.extname(file) == ".erb"
          :erb
        else
          :markdown
        end
      end

      # Parse layout file, making available all configuration entries.
      #
      private def parse_layout(html)
        toc = TOC::HTML.generate(html)
        content = Footnotes::HTML.process(toc.content).html.css("body").first.inner_html

        locals = config.merge({
                                content: content,
                                toc: toc.to_html,
                                changelog: render_changelog
                              })

        render_template(root_dir.join("templates/html/layout.erb"), locals)
      end

      # Render changelog file.
      # This file can be used to inform any book change.
      #
      private def render_changelog
        changelog = Dir[root_dir.join("text/CHANGELOG.*")].first
        render_file(changelog) if changelog
      end

      # Render all +files+ from a given chapter.
      #
      private def render_chapter(files)
        "".tap do |chapter|
          files.each do |file|
            chapter << render_file(file) << "\n\n"
          end
        end
      end

      # Copy images
      #
      private def copy_images!
        copy_directory("images", "output/images")
      end

      # Copy font files
      #
      private def copy_fonts!
        copy_directory("fonts", "output/fonts")
      end

      # Export all root stylesheets.
      #
      private def export_stylesheets!
        Exporter::CSS.new(root_dir).export
      end
    end
  end
end
