# frozen_string_literal: false

module Kitabu
  module Footnotes
    class Base
      # Set the content that will be modified.
      attr_accessor :content

      # Set the Nokogiri html object.
      attr_accessor :html

      # Set the footnote index.
      attr_reader :footnote_index

      # Process content, fixing footnotes numbering.
      # Returns a string representing the new markup.
      #
      def self.process(content)
        footnotes = new(content)
        footnotes.process
        footnotes
      end

      def initialize(content)
        @content = content
        @html = Nokogiri::HTML(content)
        @footnote_index = 1
      end

      def increment_footnote_index!
        @footnote_index += 1
      end
    end
  end
end
