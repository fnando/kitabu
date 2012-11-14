module Kitabu
  module TOC
    class HTML
      # Return the table of contents in hash format.
      #
      attr_reader :toc

      private_class_method :new
      attr_reader :buffer # :nodoc:
      attr_reader :attrs # :nodoc:
      attr_accessor :content # :nodoc:

      # Traverse every title and add a +id+ attribute.
      # Return the modified content.
      #
      def self.normalize(content)
        counter = {}
        html = Nokogiri::HTML.parse(content)
        html.search("h1, h2, h3, h4, h5, h6").each do |tag|
          title = tag.inner_text
          permalink = title.to_permalink

          counter[permalink] ||= 0
          counter[permalink] += 1

          permalink = "#{permalink}-#{counter[permalink]}" if counter[permalink] > 1

          tag.set_attribute("id", permalink)
        end

        html.css("body").to_xhtml.gsub(/<body>(.*?)<\/body>/m, "\\1")
      end

      # Traverse every title normalizing its content as a permalink.
      #
      def self.generate(content)
        content = normalize(content)
        listener = new
        listener.content = content
        Stream.new(content, listener).parse
        listener
      end

      def initialize # :nodoc:
        @toc = []
        @counters = {}
      end

      def tag(node) # :nodoc:
        toc << {
          :level     => node.name.gsub(/[^\d]/, "").to_i,
          :text      => node.text,
          :permalink => node["id"]
        }
      end

      # Return a hash with all normalized attributes.
      #
      def to_hash
        {
          :content => content,
          :html => to_html,
          :toc => toc
        }
      end

      # Return the table of contents in HTML format.
      #
      def to_html
        String.new.tap do |html|
          toc.each do |options|
            html << %[<div class="level#{options[:level]} #{options[:permalink]}"><a href="##{options[:permalink]}"><span>#{CGI.escape_html(options[:text])}</span></a></div>]
          end
        end
      end
    end
  end
end
