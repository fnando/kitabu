# frozen_string_literal: true

module Kitabu
  module TOC
    class HTML
      attr_reader :html

      Result = Struct.new(:toc, :html, :hierarchy, keyword_init: true)

      def self.generate(html)
        toc = new(html)

        Result.new(toc: toc.to_html, html: toc.html, hierarchy: toc.hierarchy)
      end

      def initialize(html)
        @html = normalize(html)
      end

      def hierarchy
        klass = Struct.new(:level, :data, :parent, keyword_init: true)

        root = klass.new(level: 1, data: {hierarchy: []})
        current = root

        html.css("h2, h3, h4, h5, h6").each do |node|
          label = node.text.strip
          level = node.name[1].to_i

          data = {
            label:,
            content: node.attributes["id"].to_s,
            hierarchy: []
          }

          if level > current.level
            current = klass.new(level:, data:, parent: current)
          elsif level == current.level
            current = klass.new(level:, data:, parent: current.parent)
          else
            while current.parent && current.parent.level >= level
              current = current.parent
            end

            current = klass.new(level:, data:, parent: current.parent)
          end

          current.parent.data[:hierarchy] << data
        end

        root.data[:hierarchy]
      end

      def to_html
        render_hierarchy(hierarchy)
      end

      def render_hierarchy(hierarchy, level = 1)
        return if hierarchy.empty?

        html = []
        html << %[<ol class="level#{level}">]

        hierarchy.each do |item|
          label = CGI.escape_html(item[:label])

          html << "<li>"
          html << %[<a href="##{item[:content]}">#{label}</a>]

          if item[:hierarchy].any?
            html << render_hierarchy(item[:hierarchy], level + 1)
          end

          html << "</li>"
        end

        html << "</ol>"

        html.join
      end

      private def normalize(html)
        counter = {}

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

        html
      end
    end
  end
end
