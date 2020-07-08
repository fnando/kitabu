# frozen_string_literal: false

module Kitabu
  module TOC
    class Epub
      attr_accessor :navigation

      def initialize(navigation)
        @navigation = navigation
      end

      def to_html
        data = OpenStruct.new(navigation: navigation).instance_eval { binding }
        ERB.new(template).result(data)
      end

      def template
        <<-HTML.strip_heredoc.force_encoding("utf-8")
          <?xml version="1.0" encoding="utf-8" ?>
          <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
          <html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
            <head>
              <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
              <link rel="stylesheet" type="text/css" href="epub.css"/>
              <meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />
              <title>Table of Contents</title>
            </head>
            <body>
              <div id="toc">
                <ul>
                  <% navigation.each do |nav| %>
                    <li>
                      <a href="<%= nav[:content] %>"><%= nav[:label] %></a>
                    </li>
                  <% end %>
                </ul>
              </div>
            </body>
          </html>
        HTML
      end
    end
  end
end
