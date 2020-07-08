# frozen_string_literal: false

module Kitabu
  module Footnotes
    class HTML < Base
      def process
        html.css(".chapter").each(&method(:process_chapter))
      end

      def process_chapter(chapter)
        footnotes = chapter.css(".footnotes").first
        return unless footnotes

        list = footnotes.css("ol").first
        list.set_attribute "start", footnote_index

        chapter.css(".footnotes li").each do |footnote|
          process_footnote(chapter, footnote)
          increment_footnote_index!
        end
      end

      def process_footnote(chapter, footnote)
        current_index = footnote.get_attribute("id").gsub(/[^\d]/m, "")
        footnote.set_attribute "id", "fn#{footnote_index}"

        process_links_to_footnote(chapter, current_index)
        process_rev_links(chapter, current_index)
        process_ref_elements(chapter, current_index)
      end

      def process_links_to_footnote(chapter, current_index)
        chapter.css("a[href='#fn#{current_index}']").each do |link|
          link.set_attribute "href", "#fn#{footnote_index}"
        end
      end

      def process_rev_links(chapter, current_index)
        chapter.css("a[href='#fnref#{current_index}']").each do |link|
          link.set_attribute "href", "#fnref#{footnote_index}"
        end
      end

      def process_ref_elements(chapter, current_index)
        chapter.css("sup[id=fnref#{current_index}]").each_with_index do |sup, index|
          if index.zero?
            sup.set_attribute "id", "fnref#{footnote_index}"
          else
            sup.remove_attribute "id"
          end

          sup.css("a").first.content = footnote_index
        end
      end
    end
  end
end
