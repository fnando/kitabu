# frozen_string_literal: true

module Kitabu
  class Exporter
    class CSS < Base
      attr_reader :root_dir

      def export
        FileUtils.cp_r(
          root_dir.join("templates/styles").to_s,
          root_dir.join("output").to_s
        )
      end
    end
  end
end
