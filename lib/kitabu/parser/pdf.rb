module Kitabu
  module Parser
    class PDF < Base
      def parse
        apply_footnotes!
        spawn_command ["prince", html_for_pdf.to_s, "-o", pdf_file.to_s]
        spawn_command ["prince", html_for_print.to_s, "-o", print_file.to_s]
      end

      def apply_footnotes!
        html = Nokogiri::HTML(html_file.read)
        footnote_count = 1

        # https://github.com/sparklemotion/nokogiri/issues/339
        html.css("html").first.tap do |element|
          next unless element
          element.delete("xmlns")
          element.delete("xml:lang")
        end

        chapters = html.css(".chapter")

        chapters.each do |chapter|
          footnotes = chapter.css(".footnotes li")

          footnotes.each do |fn|
            # Get current footnote number
            footnote_number = footnote_count
            footnote_count += 1

            # Remove rev links
            fn.css('[rev=footnote]').map(&:remove)

            # Create an element for storing the footnote description
            fn_desc = Nokogiri::XML::Node.new('span', Nokogiri::HTML::DocumentFragment.parse(''))
            fn_desc.set_attribute 'class', 'fn-desc'
            fn_desc.inner_html = fn.css('p').map(&:inner_html).join("\n")

            # Find ref based on footnote's id
            fn_id = fn.get_attribute('id')
            ref = chapter.css("a[href='##{fn_id}']").first

            # Go up to parent and reformat it.
            sup = ref.parent
            sup.delete("id")
            sup.set_attribute 'class', 'fn-ref'
            sup.inner_html = ''

            # Finally, add the description after the <sup> tag.
            sup.after(fn_desc)
          end

          # Remove the footnotes element
          chapter.css('.footnotes').map(&:remove)
        end

        create_html_file(html_for_print, html, 'print')
        create_html_file(html_for_pdf, html, 'pdf')
      end

      def create_html_file(target, html, class_name)
        html.css("html").first.set_attribute "class", class_name
        html.css("link[name=stylesheet]").first.set_attribute "href", "styles/#{class_name}.css"
        File.open(target, "w") {|f| f << html.to_html }
      end

      def html_for_pdf
        root_dir.join("output/#{name}.pdf.html")
      end

      def html_for_print
        root_dir.join("output/#{name}.print.html")
      end

      def html_file
        root_dir.join("output/#{name}.html")
      end

      def pdf_file
        root_dir.join("output/#{name}.pdf")
      end

      def print_file
        root_dir.join("output/#{name}.print.pdf")
      end
    end
  end
end
