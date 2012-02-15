module Kitabu
  module Parser
    class Epub < Html

      module Toc
        HEAD = <<-HEAD
        <?xml version='1.0' encoding='utf-8' ?>
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
        <html xml:lang='en' xmlns='http://www.w3.org/1999/xhtml'>
          <head>
            <meta content='application/xhtml+xml; charset=utf-8' http-equiv='Content-Type' />
            <title>Table of Contents</title>
          </head>
          <body>
            <div id='toc'>
              <ul>
        HEAD

        TAIL = <<-TAIL
              </ul>
            </div>
          </body>
        </html>
        TAIL

        def generate_html(nav)
          HEAD + 
          nav.map { |element| 
            "<li><a href='#{element[:content]}'>#{element[:label]}</a></li>"
          }.join + 
          TAIL
        end

        def generate_file(*args)
          filename = "tmp/toc.html"
          File.open(filename, 'w') { |file| file.write generate_html(*args) }
          filename
        end
        module_function :generate_file, :generate_html
      end

      attr_accessor :epub

      def initialize(*args)
        super
        FileUtils.mkdir_p('tmp')
        @epub = EeePub::Maker.new
      end

      def parse
        epub.title        config[:title]
        epub.language     config[:language]
        epub.creator      config[:authors].to_sentence
        epub.publisher    config[:publisher]
        epub.date         config[:published_at]
        epub.uid          config[:uid]
        epub.identifier   config[:identifier][:id], :scheme => config[:identifier][:type]
        epub.cover_page   cover_image

        assets            = collect_assets
        sections          = collect_sections
        filenames         = collect_filenames(sections)

        epub.files        filenames + assets
        epub.nav          collect_nav(sections, filenames)

        epub.toc_page     Toc.generate_file collect_nav(sections, filenames)

        epub.save(epub_path)
        true
      rescue Exception
        p $!, $@
        false
      end

      def collect_assets
        [cover_image, File.join(root_dir, "templates", "epub", "style.css")].compact
      end

      def cover_image
        path = root_dir.join('images/cover-epub.jpg')
        return path if File.exist?(path)
      end

      def chapter(entry)
        files = chapter_files(entry)
        content = replace_paths(render_chapter(files, true))
        html = Nokogiri(content)
        title = html.css("h2").first.text

        [
          title,
          render_template(
            root_dir.join("templates/epub/page.erb"),
            {:chapter_title => title, :content => content, :language => config[:language]}
          )
        ]
      end

      def collect_sections
        entries.map { |entry| chapter(entry) }
      end

      def collect_filenames(sections)
        index = 0
        
        sections.map do |section|
          index += 1
          
          filename = "tmp/section_#{index}.html"
          File.open(filename, 'w') { |file| file.write section[1] }
          filename
        end
      end
      
      def collect_nav(sections, filenames)
        [sections, filenames].transpose.map do |section, filename|
          {:label => section[0], :content => File.basename(filename)}
        end
      end

      def replace_paths(text)
        text.gsub(%r[src="(.*?)"]) {|m| %[src="#{File.basename($1)}"]}
      end

      def epub_path
        root_dir.join("output/#{name}.epub")
      end
    end
  end
end
