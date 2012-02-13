module Kitabu
  module Parser
    class Pdf < Base
      def parse
        command = ["prince", html_file.to_s, "-o", pdf_file.to_s]
        puts command

        system(*command)
        true
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
