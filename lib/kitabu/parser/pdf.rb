module Kitabu
  module Parser
    class Pdf < Base
      def parse
        command = ["prince", html_file.to_s, "-o", pdf_file.to_s]
        Kitabu.logger.info command.join(" ")

        Open3.popen3(*command) do |stdin, stdout, stderr|
          lines = stderr.readlines
          Kitabu.logger.error lines.join("\n")
          return lines.reject {|line| line =~ /prince.*?license.dat/}.empty?
        end
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
