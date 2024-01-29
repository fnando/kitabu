# frozen_string_literal: true

module Kitabu
  class Exporter
    class HTML < Base
      # Parse all files and save the parsed content
      # to `output/book_name.html`.
      #
      def export
        super
        copy_assets
        export_kitabu_css

        File.open(root_dir.join("output/#{name}.html"), "w") do |file|
          file << render_layout
        end

        true
      rescue StandardError => error
        handle_error(error)
        false
      end

      # Return all sections wrapped in a `section` tag.
      #
      def content
        buffer = [].tap do |content|
          source_list.each_section do |files|
            # To retrieve the section identifier, only the first file's matter
            # must be retrieved, because all section files will be merged into
            # one big html file.
            matter = FrontMatter.parse(File.read(files.first))
            matter.meta["section"] ||= "chapter"

            content << <<~ERB
              <section class="#{matter.meta['section']} section">
                #{render_section(files, matter.meta)}
              </section>
            ERB
          end
        end

        buffer.join
      end

      # Render `file` considering its extension.
      #
      private def render_file(file_path, meta)
        matter = FrontMatter.parse(File.read(file_path))
        meta = meta.merge(matter.meta)

        content = if file_format(file_path) == :erb
                    render_template(matter.content, config.merge(meta:))
                  else
                    matter.content
                  end

        Kitabu::Markdown.render(content)
      end

      private def file_format(file_path)
        if File.extname(file_path) == ".erb"
          :erb
        else
          :markdown
        end
      end

      # Parse layout file, making available all configuration entries.
      #
      private def render_layout
        html = Nokogiri::HTML(content)
        html = Footnotes::HTML.process(html)
        toc = TOC::HTML.generate(html)
        html = toc.html

        locals = config.merge(
          content: html.css("body").first.inner_html,
          toc: toc.toc
        )

        render_template(root_dir.join("templates/html/layout.erb").read, locals)
      end

      # Render all `files` from a given section.
      #
      private def render_section(files, meta)
        buffer = [].tap do |section|
          files.each do |file|
            section << render_file(file, meta) << "\n\n"
          end
        end

        buffer.join
      end

      # Copy assets
      #
      private def copy_assets
        copy_directory("assets", "output/assets")
      end

      # Export css with utilities for syntax highlighting, translations, and
      # accent color.
      #
      private def export_kitabu_css
        CSS.create_file(config:, root_dir:)
      end
    end
  end
end
