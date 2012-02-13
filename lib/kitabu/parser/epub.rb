module Kitabu
  module Parser
    class Epub < Html
      attr_accessor :epub

      def initialize(*args)
        super
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
        epub.cover_page   root_dir.join('images/cover-epub.jpg')

        assets            = collect_assets
        sections          = collect_sections
        filenames         = collect_filenames(sections)

        epub.files        filenames + assets
        epub.nav          collect_nav(sections, filenames)

        epub.save(epub_path)
        true
      rescue Exception
        p $!, $@
        false
      end

      def collect_assets
        [File.join(root_dir, "templates", "epub.css")]
      end

      def chapter(entry)
        files = chapter_files(entry)
        content = replace_paths(render_chapter(files, true))
        html = Nokogiri(content)
        title = html.css("h2").first.text

        [
          title,
          render_template(
            root_dir.join("templates/epub.erb"),
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
          
          filename = File.join(root_dir, "tmp", "section_#{index}.html")
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
