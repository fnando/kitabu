# frozen_string_literal: false

module Kitabu
  module Helpers
    def image_tag(path, _attributes = {})
      %[<img alt="" src="assets/images/#{path}" />]
    end

    def escape_html(content)
      CGI.escape_html(content.to_s)
    end
    alias h escape_html

    def note(class_name = :info, &block)
      content = block_content(block)
      type = class_name.to_s
      title = I18n.t(
        type,
        scope: :notes,
        default: type.titleize
      )
      output << format(
        '<div class="note %{type}">',
        type: escape_html(class_name)
      )
      output << format(
        '<p class="note--title">%{title}</p>',
        title: escape_html(title)
      )
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
