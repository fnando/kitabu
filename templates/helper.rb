# frozen_string_literal: true

module Kitabu
  module Helpers
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
