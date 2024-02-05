# frozen_string_literal: true

module Kitabu
  module TOC
    class HTML
      attr_reader :html

      Result = Struct.new(:toc, :html, :hierarchy, keyword_init: true)

      def self.generate(html)
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
    end
  end
end
