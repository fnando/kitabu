# frozen_string_literal: false

module Kitabu
  class Exporter
    class Mobi < Base
      def export
        spawn_command ["kindlegen", epub_file.to_s]
        true
      end

      def epub_file
        root_dir.join("output/#{name}.epub")
      end
    end
  end
end
