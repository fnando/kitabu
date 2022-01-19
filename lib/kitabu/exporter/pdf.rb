# frozen_string_literal: true

module Kitabu
  class Exporter
    class PDF < Base
      def export
        apply_footnotes!
        spawn_command ["prince", html_for_pdf.to_s, "-o", pdf_file.to_s]
        spawn_command ["prince", html_for_print.to_s, "-o", print_file.to_s]
      end

      def apply_footnotes!
        html = Footnotes::PDF.process(html_file.read).html
        create_html_file(html_for_print, html, "print")
        create_html_file(html_for_pdf, html, "pdf")
      end

      def create_html_file(target, html, class_name)
        html.css("html").first.set_attribute "class", class_name
        html
          .css("link[name=stylesheet]")
          .first
          .set_attribute "href", "styles/#{class_name}.css"

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
