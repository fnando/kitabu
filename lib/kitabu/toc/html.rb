# frozen_string_literal: true

module Kitabu
  module TOC
    class HTML
      # Return the table of contents in hash format.
      #
      attr_reader :toc

      private_class_method :new
      attr_reader :buffer, :attrs
      attr_accessor :content

      # Traverse every title and add an +id+ attribute.
      # Return the modified content.
      #
      def self.normalize(content)
        counter = {}
        html = Nokogiri::HTML.parse(content)
        html.search("h1, h2, h3, h4, h5, h6").each do |tag|
          title = tag.inner_text.strip
          permalink = title.to_permalink

          counter[permalink] ||= 0
          counter[permalink] += 1

          if counter[permalink] > 1
            permalink = "#{permalink}-#{counter[permalink]}"
          end

          tag.set_attribute("id", permalink)
          tag["tabindex"] = "-1"
          tag.prepend_child %[<a class="anchor" href="##{permalink}" aria-hidden="true" tabindex="-1"></a>] # rubocop:disable Style/LineLength
        end

        html.css("body").first.inner_html
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
          level: node.name.gsub(/[^\d]/, "").to_i,
          text: node.text.strip,
          permalink: node["id"]
        }
      end

      # Return a hash with all normalized attributes.
      #
      def to_hash
        {
          content:,
          html: to_html,
          toc:
        }
      end

      # Return the table of contents in HTML format.
      #
      def to_html
        buffer =
          toc.each_with_object([]) do |options, html|
            html << %[
              <div class="level#{options[:level]} #{options[:permalink]}">
                <a href="##{options[:permalink]}">
                  <span>#{CGI.escape_html(options[:text])}</span>
                </a>
              </div>
            ]
          end

        buffer.join
      end
    end
  end
end
