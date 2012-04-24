module Kitabu
  module Parser
    class Pdf < Base
      def parse
        content = File.read(html_file)
        prince_friendly_footnotes = transform_footnotes(content)

        transformed_html_file = File.new('output/prince_friendly_footnote_file.html', 'w')
        transformed_html_file.write prince_friendly_footnotes

        command = ["prince", transformed_html_file.path, "-o", pdf_file.to_s]
        Process.wait Process.spawn(*command)

        transformed_html_file.close
        File.unlink(transformed_html_file)
        true
      end

      def transform_footnotes(content)
        doc = Nokogiri::HTML(content)
        doc.css('a').each do |node|
          prince_friendly_footnote = <<-FN
            #{node.text}<span class='fn'><a href='#{node['href']}'>#{node['href']}</a></span>
          FN

          node.replace(prince_friendly_footnote)
        end

        doc.to_xhtml
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
