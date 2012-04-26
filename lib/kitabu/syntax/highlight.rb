module Kitabu
  class Syntax
    class Highlight
      def self.apply(code, language)
        if defined?(Pygments)
          pygments(code, language)
        else
          coderay(code, language)
        end
      end

      private
      def self.pygments(code, language)
        Pygments.highlight(code, :lexer => language, :options => {:encoding => "utf-8"})
      end

      def self.coderay(code, language)
        CodeRay.scan(code, language).div(:css => :class)
      end
    end
  end
end
