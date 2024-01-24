# frozen_string_literal: true

module Kitabu
  module TOC
    class Epub
      attr_accessor :navigation

      def initialize(navigation)
        @navigation = navigation
      end

      def to_html
        data = OpenStruct
               .new(navigation:, helpers: self)
               .instance_eval { binding }
        ERB.new(template).result(data)
      end

      def render_navigation(nav)
        return if nav.empty?

        html = []
        html << "<ol>"

        nav.each do |item|
          html << "<li>"
          html << %[<a href="#{item[:content]}">#{item[:label]}</a>]
          html << render_navigation(item[:nav]) if item[:nav].any?
          html << "</li>"
        end

        html << "</ol>"

        html.join
      end

      def template
        (+<<-HTML).strip_heredoc.force_encoding("utf-8")
          <?xml version="1.0" encoding="utf-8" ?>
          <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
          <html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
            <head>
              <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
              <link rel="stylesheet" type="text/css" href="epub.css"/>
              <meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />
              <title><%= I18n.t(:table_of_contents, default: "Table of Contents") %></title>
            </head>
            <body>
              <div id="toc">
                <%= helpers.render_navigation(navigation) %>
              </div>
            </body>
          </html>
        HTML
      end
    end
  end
end
