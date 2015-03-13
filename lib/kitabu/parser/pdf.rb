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

        # https://github.com/sparklemotion/nokogiri/issues/339
        html.css("html").first.tap do |element|
          next unless element
          element.delete("xmlns")
          element.delete("xml:lang")
        end

        html.css("p.footnote[id^='_fn']").each do |fn|
          fn.node_name = "span"
          fn.set_attribute("class", "fn")

          html.css("[href='##{fn["id"]}']").each do |link|
            link.add_next_sibling(fn)
          end
        end

        create_html_file(html_for_print, html, 'print')
        create_html_file(html_for_pdf, html, 'pdf')

      end

      def create_html_file(target, html, class_name)
        html.css("html").first.set_attribute "class", class_name
        html.css("link[name=stylesheet]").first.set_attribute "href", "styles/#{class_name}.css"
        File.open(target, "w") {|f| f << html.to_xhtml }
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
