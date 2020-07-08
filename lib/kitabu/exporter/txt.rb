# frozen_string_literal: false

module Kitabu
  class Exporter
    class Txt < Base
      def export
        spawn_command ["html2text", "-style", "pretty", "-nobs", "-o", txt_file.to_s, html_file.to_s]
      end

      def html_file
        root_dir.join("output/#{name}.html")
      end

      def txt_file
        root_dir.join("output/#{name}.txt")
      end
    end
  end
end
