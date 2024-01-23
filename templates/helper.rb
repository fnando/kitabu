# frozen_string_literal: true

module Kitabu
  # If you need to process the markdown before rendering it, you can use the
  # `before_markdown_render` hook.
  #
  # Kitabu.add_hook(:before_markdown_render) do |content|
  #   content
  # end

  # Similarly, you can manipulate the generated HTML by using the hook
  # `after_markdown_render`.
  #
  # Kitabu.add_hook(:after_markdown_render) do |content|
  #   html = Nokogiri::HTML(content)
  #
  #   # Do something with HTML here.
  #
  #   html.to_html
  # end

  module Helpers
    # This method is just a helper example.
    # Feel free to remove it once you get rid of the sample output.
    def lexers_list
      buffer = [%[<ul class="lexers">]]

      Rouge::Lexers.constants.each do |const|
        lexer = Rouge::Lexers.const_get(const)

        begin
          title = lexer.title
          tag = lexer.tag
          description = lexer.desc
        rescue StandardError
          next
        end

        buffer << "<li>"
        buffer << "<strong>#{title}</strong> "
        buffer << "<code>#{tag}</code><br>"
        buffer << "<span>#{description}</span>"
        buffer << "</li>"
      end

      buffer << "</ul>"
      buffer.join
    end
  end
end
