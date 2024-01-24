# frozen_string_literal: true

module Kitabu
  module TOC
    class HTML
      attr_reader :navigation

      def self.generate(navigation)
        new(navigation).to_html
      end

      def initialize(navigation)
        @navigation = navigation
      end

      def to_html
        render_navigation(navigation)
      end

      def render_navigation(nav, level = 1)
        return if nav.empty?

        html = []
        html << %[<ol class="level#{level}">]

        nav.each do |item|
          html << "<li>"
          html << %[<a href="##{item[:content]}">#{item[:label]}</a>]
          html << render_navigation(item[:nav], level + 1) if item[:nav].any?
          html << "</li>"
        end

        html << "</ol>"

        html.join
      end
    end
  end
end
