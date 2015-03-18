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
          listener.tag(node) if node.name =~ /h[1-6]/
        end
      end
    end
  end
end
