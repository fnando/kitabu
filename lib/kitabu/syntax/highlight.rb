# frozen_string_literal: true

module Kitabu
  class Syntax
    class Highlight
      def self.apply(code, language)
        coderay(code, language)
      end

      def self.coderay(code, language)
        html = Nokogiri::HTML(CodeRay.scan(code, language).div(css: :class))
        coderay = html.css("div.CodeRay").first
        coderay.set_attribute "class", "CodeRay #{language}"
        pre = html.css("pre").first
        pre.replace Nokogiri.make("<pre><code>#{pre.inner_html}</code></pre>")

        coderay.to_xhtml
      end
    end
  end
end
