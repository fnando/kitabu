module Kitabu
  module Parser
    class Mobi < Base
      def parse
        command = ["kindlegen", epub_file.to_s,]
        Kitabu.logger.info command.join(" ")

        Open3.popen3(*command) do |stdin, stdout, stderr|
          lines = stderr.readlines
          Kitabu.logger.error lines.join("\n")
          return lines
        end
      end

      def epub_file
        root_dir.join("output/#{name}.epub")
      end
    end
  end
end
