# frozen_string_literal: true

module Kitabu
  class Exporter
    class Mobi < Base
      def export
        super
        spawn_command ["ebook-convert", epub_file.to_s, mobi_file.to_s]
        true
      end

      def mobi_file
        root_dir.join("output/#{name}.mobi")
      end

      def epub_file
        root_dir.join("output/#{name}.epub")
      end
    end
  end
end
