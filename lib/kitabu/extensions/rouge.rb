# frozen_string_literal: true

module Rouge
  module Plugins
    module Redcarpet
      def rouge_formatter(lexer)
        options = lexer.respond_to?(:options) ? lexer.options : {}
        options = options.keys.map(&:to_sym).zip(options.values).to_h
        options[:start_line] = options.fetch(:start_line, 1).to_i

        options = options.keys.map(&:to_sym).zip(options.values).to_h

        Formatters::HTMLLegacy.new(
          {css_class: "highlight #{lexer.tag}"}.merge(options)
        )
      end
    end
  end
end
