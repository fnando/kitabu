module Rouge
  module Plugins
    module Redcarpet
      def rouge_formatter(lexer)
        options = lexer.respond_to?(:options) ? lexer.options : {}
        Formatters::HTML.new({css_class: "highlight #{lexer.tag}"}.merge(options))
      end
    end
  end
end
