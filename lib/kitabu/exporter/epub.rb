# frozen_string_literal: true

module Kitabu
  class Exporter
    class Epub < Base
      SECTION_SELECTOR =
        "div.chapter, div.section, section.chapter, section.section"

      def sections
        @sections ||=
          html.css(SECTION_SELECTOR).each_with_index.map do |chapter, index|
            html = Nokogiri::HTML5.fragment(chapter.inner_html)

            OpenStruct.new(
              index:,
              filename: "section_#{index}.html",
              filepath: tmp_dir.join("section_#{index}.html").to_s,
              html:
            )
          end
      end

      def epub
        @epub ||= ::Epub.new(
          root_dir: tmp_dir,
          title: config[:title],
          subtitle: config[:subtitle],
          language: config[:language],
          copyright: config[:copyright],
          publisher: config[:publisher],
          contributors: Array(config[:contributors]),
          creators: Array(config[:creators]),
          identifiers: Array(config[:identifiers]),
          date: config[:published_at] || Date.today.to_s
        )
      end

      def html
        @html ||= Nokogiri::HTML(html_path.read)
      end

      def export
        super

        copy_assets

        write_sections!
        write_cover!
        write_toc!

        ignore_files = [
          tmp_dir.join("assets/styles/html.css"),
          tmp_dir.join("assets/styles/print.css"),
          tmp_dir.join("assets/styles/pdf.css")
        ].map(&:to_s)

        epub.files += [tmp_dir.join("cover.html"), tmp_dir.join("toc.html")]
        epub.files += tmp_dir.glob("**/*").select do |entry|
          !epub.files.include?(entry) &&
            entry.file? &&
            !ignore_files.include?(entry.to_s)
        end

        epub.save(epub_path)

        true
      rescue StandardError => error
        handle_error(error)
        false
      end

      def copy_assets
        copy_directory("output/assets", "output/epub/assets")
      end

      def write_toc!
        root_dir.join(toc_path).open("w") do |io|
          io << render_template(
            root_dir.join("templates/epub/toc.erb").read,
            config.merge(
              navigation: ::Epub::Navigation.extract_html(
                tmp_dir.glob("**/*.{xhtml,html}"),
                root_dir: tmp_dir
              )
            )
          )
        end
      end

      def write_cover!
        root_dir.join(cover_path).open("w") do |io|
          io << render_template(
            root_dir.join("templates/epub/cover.erb").read,
            config
          )
        end
      end

      def write_sections!
        sections.each do |section|
          # Remove anchors (only useful for html exports).
          #
          section.html.css("a.anchor").each(&:remove)

          # Remove tabindex (only useful for html exports).
          #
          section.html.css("[tabindex]").each do |node|
            node.remove_attribute("tabindex")
          end

          FileUtils.mkdir_p(tmp_dir)

          # Save file to disk.
          #
          File.open(section.filepath, "w") do |file|
            content = section.html.to_xhtml

            page_title = section.html.css("h2").first.text.strip
            locals = config.merge(content:, page_title:)

            file << render_template(File.read(template_path), locals)
          end
        end
      end

      def template_path
        root_dir.join("templates/epub/page.erb")
      end

      def html_path
        root_dir.join("output/#{name}.html")
      end

      def epub_path
        root_dir.join("output/#{name}.epub")
      end

      def tmp_dir
        root_dir.join("output/epub")
      end

      def toc_path
        tmp_dir.join("toc.html")
      end

      def cover_path
        tmp_dir.join("cover.html")
      end
    end
  end
end
