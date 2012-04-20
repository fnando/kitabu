module Kitabu
  module Parser
    class Mobi < Base
      def parse
        command = ["kindlegen", epub_file.to_s,]
        puts command

        Process.wait Process.spawn(*command)
        true
      end

      def epub_file
        root_dir.join("output/#{name}.epub")
      end
    end
  end
end
