module Kitabu
  module Parser
    class Mobi < Base
      def parse
        spawn_command ["kindlegen", epub_file.to_s]
        true
      end

      def epub_file
        root_dir.join("output/#{name}.epub")
      end
    end
  end
end
