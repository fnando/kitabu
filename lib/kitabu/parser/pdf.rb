module Kitabu
  module Parser
    class Pdf < Base
      def parse
        IO.popen("prince %s -o %s" % [html_file, pdf_file]).close
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
