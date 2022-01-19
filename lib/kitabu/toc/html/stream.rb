# frozen_string_literal: true

module Kitabu
  module TOC
    class HTML
      class Stream
        attr_accessor :listener, :content
        attr_reader :html

        def initialize(content, listener)
          @content  = content
          @listener = listener
          @html = Nokogiri::HTML.parse(content)
        end

        def parse
          traverse(html)
        end

        def traverse(node)
          node.children.each do |child|
            emit(child)
            traverse(child)
          end
        end

        def emit(node)
          listener.tag(node) if /h[1-6]/.match?(node.name)
        end
      end
    end
  end
end
