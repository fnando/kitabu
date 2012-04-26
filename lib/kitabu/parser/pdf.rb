module Kitabu
  module Parser
    class Pdf < Base
      def parse
        apply_footnotes!

        command = ["prince", with_footnotes_file.to_s, "-o", pdf_file.to_s]
        Process.wait Process.spawn(*command)
        true
      end

      def apply_footnotes!
        html = Nokogiri::HTML(html_file.read)

        # https://github.com/tenderlove/nokogiri/issues/339
        html.css("html").first.tap do |element|
          next unless element
          element.delete("xmlns")
          element.delete("xml:lang")
        end

        html.css("p.footnote[id^='fn']").each do |fn|
          fn.node_name = "span"
          fn.set_attribute("class", "fn")

          html.css("[href='##{fn["id"]}']").each do |link|
            link.add_next_sibling(fn)
          end
        end

        File.open(with_footnotes_file, "w+") {|f| f << html.to_xhtml}
      end

      def with_footnotes_file
        root_dir.join("output/#{name}.pdf.html")
      end

      def html_file
        root_dir.join("output/#{name}.html")
      end

      def pdf_file
        root_dir.join("output/#{name}.pdf")
      end
    end
  end
end
