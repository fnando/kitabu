# frozen_string_literal: true

module Kitabu
  module TOC
    class HTML
      attr_reader :html

      Result = Struct.new(:toc, :html, :hierarchy, keyword_init: true)

      def self.generate(html)
        html = normalize(html)
        file = Tempfile.new("kitabu")
        file.write(html.to_s)
        file.close

        toc = ::Epub::Navigation.extract_html(
          [file.path],
          root_dir: File.dirname(file.path)
        )

        toc_html = Nokogiri::HTML(toc).css("nav").first
        toc_html.remove_attribute "epub:type"
        toc = toc_html.to_s

        Result.new(toc:, html:)
      ensure
        file.unlink
      end

      def self.normalize(html)
        counter = {}

        html.search("h1, h2, h3, h4, h5, h6").each do |tag|
          title = tag.inner_text.strip
          permalink = title.to_permalink

          counter[permalink] ||= 0
          counter[permalink] += 1

          if counter[permalink] > 1
            permalink = "#{permalink}-#{counter[permalink]}"
          end

          tag.set_attribute("id", permalink)
          tag["tabindex"] = "-1"

          tag.prepend_child %[<a class="anchor" href="##{permalink}" aria-hidden="true" tabindex="-1"></a>] # rubocop:disable Style/LineLength
        end

        html
      end
    end
  end
end
