# frozen_string_literal: true

module Kitabu
  module Footnotes
    class Base
      # Set the Nokogiri html object.
      attr_reader :html

      # Set the footnote index.
      attr_reader :footnote_index

      # Process content, fixing footnotes numbering.
      # Returns a string representing the new markup.
      #
      def self.process(html)
        new(html).process
        html
      end

      def initialize(html)
        @html = html
        @footnote_index = 1
      end

      def increment_footnote_index!
        @footnote_index += 1
      end
    end
  end
end
