# frozen_string_literal: true

module Kitabu
  class Exporter
    class Epub < Base
      def sections
        @sections ||=
          html.css("div.chapter").each_with_index.map do |chapter, index|
            html = Nokogiri::HTML(chapter.inner_html)

            OpenStruct.new(
              index:,
              filename: "section_#{index}.html",
              filepath: tmp_dir.join("section_#{index}.html").to_s,
              html:
            )
          end
      end

      def epub
        @epub ||= EeePub::Maker.new
      end

      def html
        @html ||= Nokogiri::HTML(html_path.read)
      end

      def export
        super

        copy_styles!
        copy_images!
        File.open(root_dir.join("output/epub/cover.html"), "w") do |io|
          io << render_template(
            root_dir.join("templates/epub/cover.erb"),
            config
          )
        end
        set_metadata!
        write_sections!
        write_toc!

        epub.files sections.map(&:filepath) + assets
        epub.nav      navigation
        epub.toc_page toc_path

        epub.save(epub_path)

        true
      rescue StandardError => error
        handle_error(error)
        false
      end

      def copy_styles!
        copy_files("output/styles/epub.css", "output/epub/styles")
        copy_files("output/styles/files/*.css", "output/epub/styles")
      end

      def copy_images!
        copy_directory("output/images", "output/epub/images")
      end

      def set_metadata!
        epub.title        config[:title]
        epub.language     config[:language]
        epub.creator      config[:authors].to_sentence
        epub.publisher    config[:publisher]
        epub.date         config[:published_at]
        epub.uid          config[:uid]
        epub.identifier   config[:identifier][:id],
                          scheme: config[:identifier][:type]

        # epubchecker complains when assigning an image directly,
        # but if we don't, then Apple Books doesn't render the cover.
        # Need to investigate some more.
        epub.cover_page   cover_image if cover_image && File.exist?(cover_image)
      end

      def write_toc!
        toc = TOC::Epub.new(navigation)

        File.open(toc_path, "w") do |file|
          file << toc.to_html
        end
      end

      def write_sections!
        # First we need to get all ids, which are used as
        # the anchor target.
        #
        links = sections.each_with_object({}) do |section, buffer|
          section.html.css("[id]").each do |element|
            anchor = "##{element['id']}"
            buffer[anchor] = "#{section.filename}#{anchor}"
          end
        end

        # Then we can normalize all links and
        # manipulate other paths.
        #
        sections.each do |section|
          section.html.css("a[href^='#']").each do |link|
            href = link["href"]
            link.set_attribute("href", links.fetch(href, href))
          end

          # Normalize <ol>
          #
          section.html.css("ol[start]").each do |node|
            node.remove_attribute("start")
          end

          # Remove anchors (only useful for html exports).
          #
          section.html.css("a.anchor").each(&:remove)

          # Remove tabindex (only useful for html exports).
          #
          section.html.css("[tabindex]").each do |node|
            node.remove_attribute("tabindex")
          end

          # Replace all srcs.
          #
          section.html.css("[src]").each do |element|
            src = File.basename(element["src"]).gsub(/\.svg$/, ".png")
            element.set_attribute("src", src)
            element.set_attribute("alt", "")
            element.node_name = "img"
          end

          FileUtils.mkdir_p(tmp_dir)

          # Save file to disk.
          #
          File.open(section.filepath, "w") do |file|
            body = section.html.css("body").to_xhtml.gsub(
              %r{<body>(.*?)</body>}m, "\\1"
            )
            file << render_chapter(body)
          end
        end
      end

      def render_chapter(content)
        locals = config.merge(content:)
        render_template(template_path, locals)
      end

      def assets
        @assets ||= begin
          assets = Dir[root_dir.join("output/epub/styles/**/*.css")]
          assets += Dir[root_dir.join("images/**/*.{jpg,png,gif}")]
          assets
        end
      end

      def cover_image
        path = Dir[root_dir.join("output/epub/images/cover.{jpg,png,gif}").to_s]
               .first

        path if path && File.exist?(path)
      end

      def navigation
        klass = Struct.new(:level, :data, :parent, keyword_init: true)

        root = klass.new(level: 1, data: {nav: []})
        current = root

        sections.each do |section|
          section.html.css("h2, h3, h4, h5, h6").each do |node|
            label = CGI.escape_html(node.text.strip)
            level = node.name[1].to_i

            data = {
              label:,
              content: "#{section.filename}##{node.attributes['id']}",
              nav: []
            }

            if level > current.level
              current = klass.new(level:, data:, parent: current)
            elsif level == current.level
              current = klass.new(level:, data:, parent: current.parent)
            else
              while current.parent && current.parent.level >= level
                current = current.parent
              end

              current = klass.new(level:, data:, parent: current.parent)
            end

            current.parent.data[:nav] << data
          end
        end

        root.data[:nav]
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
    end
  end
end
