# frozen_string_literal: false

module Kitabu
  module Helpers
    def highlight_theme(name = theme)
      html = '<style type="text/css">'
      html << Rouge::Theme.find(name).render(scope: ".highlight")
      html << "</style>"
      html
    end

    def image_tag(path, _attributes = {})
      %[<img src="images/#{path}" />]
    end

    def escape_html(content)
      CGI.escape_html(content.to_s)
    end

    def note(class_name = :info, &block)
      content = block_content(block)
      output << ('<div class="note %s">' % escape_html(class_name)) # rubocop:disable Style/FormatString
      output << markdown(content)
      output << "</div>"
    end

    def block_content(block)
      output = @_output.dup
      @_output = ""
      content = block.call
      @_output = output
      content
    end

    def markdown(content, deindent_content: true)
      content = deindent(content) if deindent_content
      Markdown.render(content)
    end

    def deindent(content)
      content = content.to_s
      indent = (content.scan(/^[ \t]*(?=\S)/) || []).size
      content.gsub(/^[ \t]{#{indent}}/, "")
    end

    def output
      @_output
    end
  end
end
