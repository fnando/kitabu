# frozen_string_literal: true

module Kitabu
  class Exporter
    class PDF < Base
      def export
        super
        apply_footnotes!
        args = Shellwords.split(ENV.fetch("PRINCEOPT", ""))
        args += Array(config[:prince_args])

        spawn_command(
          ["prince", *args, html_for_pdf.to_s, "-o", pdf_file.to_s]
        )

        spawn_command(
          ["prince", *args, html_for_print.to_s, "-o", print_file.to_s]
        )
      end

      def apply_footnotes!
        html = Nokogiri::HTML5(html_file.read)
        html = Footnotes::PDF.process(html)
        create_html_file(html_for_print, html, "print")
        create_html_file(html_for_pdf, html, "pdf")
      end

      def create_html_file(target, html, class_name)
        html.css("body").first.set_attribute "class", class_name
        html
          .css("link[rel=stylesheet]")
          .first
          .set_attribute "href", "assets/styles/#{class_name}.css"

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
