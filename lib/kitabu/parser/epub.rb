module Kitabu
  module Parser
    class Epub < Html
      attr_accessor :epub

      def initialize(*args)
        super
        @epub = EeePub::Easy.new
      end

      def parse
        epub.title        config[:title]
        epub.language     config[:language]
        epub.creator      config[:authors].to_sentence
        epub.publisher    config[:publisher]
        epub.date         config[:published_at]
        epub.uid          config[:uid]
        epub.identifier   config[:identifier][:id], :scheme => config[:identifier][:type]
        set_assets
        set_chapters
        epub.save(epub_path)
      end

      def set_assets
        epub.assets << Kitabu::ROOT.join("templates/epub.css")
        Dir[root_dir.join("images/**/*")].each {|i| epub.assets << i}
      end

      def chapter(entry)
        files = chapter_files(entry)
        content = replace_paths(render_chapter(files))
        html = Nokogiri(content)
        title = html.css("h2").first.text

        [
          title,
          render_template(
            Kitabu::ROOT.join("templates/page.erb"),
            {:chapter_title => title, :content => content}
          )
        ]
      end

      def set_chapters
        entries.each do |entry|
          epub.sections << chapter(entry)
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
