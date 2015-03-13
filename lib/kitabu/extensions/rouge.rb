module Rouge
  module Plugins
    module Redcarpet
      def rouge_formatter(lexer)
        Formatters::HTML.new({css_class: "highlight #{lexer.tag}"}.merge(lexer.options))
      end
    end
  end
end
