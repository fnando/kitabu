# frozen_string_literal: true

module Kitabu
  module TOC
    class Epub
      attr_accessor :hierarchy

      def initialize(hierarchy)
        @hierarchy = hierarchy
      end

      def to_html
        data = OpenStruct
               .new(hierarchy:, helpers: self)
               .instance_eval { binding }
        ERB.new(template).result(data)
      end

      def render_hierarchy(hierarchy)
        return if hierarchy.empty?

        html = []
        html << "<ol>"

        hierarchy.each do |item|
          label = CGI.escape_html(item[:label])

          html << "<li>"
          html << %[<a href="#{item[:content]}">#{label}</a>]
          html << render_hierarchy(item[:hierarchy]) if item[:hierarchy].any?
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
              <link rel="stylesheet" type="text/css" href="styles/epub.css" />
              <meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />
              <title><%= I18n.t(:contents, default: "Contents") %></title>
            </head>
            <body>
              <div id="toc">
                <%= helpers.render_hierarchy(hierarchy) %>
              </div>
            </body>
          </html>
        HTML
      end
    end
  end
end
