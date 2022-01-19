# frozen_string_literal: true

module Kitabu
  module Footnotes
    class PDF < Base
      def process
        remove_duplicated_attributes
        html.css(".chapter").each(&method(:process_chapter))
      end

      def remove_duplicated_attributes
        # https://github.com/sparklemotion/nokogiri/issues/339
        html.css("html").first.tap do |element|
          next unless element

          element.delete("xmlns")
          element.delete("xml:lang")
        end
      end

      def process_chapter(chapter)
        chapter.css(".footnotes li").each do |footnote|
          process_footnote(chapter, footnote)
          increment_footnote_index!
        end

        chapter.css(".footnotes").each(&:remove)
      end

      def process_footnote(chapter, footnote)
        # Remove rev links
        footnote.css("[rev=footnote]").map(&:remove)

        # Create an element for storing the footnote description
        description = Nokogiri::XML::Node.new(
          "span",
          Nokogiri::HTML::DocumentFragment.parse("")
        )
        description.set_attribute "class", "footnote"
        description.inner_html = footnote.css("p").map(&:inner_html).join("\n")

        # Find ref based on footnote's id
        fn_id = footnote.get_attribute("id")

        chapter.css("a[href='##{fn_id}']").each do |ref|
          sup = ref.parent
          sup.after(description)
          sup.remove
        end
      end
    end
  end
end
