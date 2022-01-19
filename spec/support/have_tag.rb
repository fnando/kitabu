# frozen_string_literal: true

module Matchers
  def have_tag(selector, options = {}, &block)
    HaveTag.new(:html, selector, options, &block)
  end

  def have_node(selector, options = {}, &block)
    HaveTag.new(:xml, selector, options, &block)
  end

  class HaveTag
    attr_reader :options, :selector, :actual, :actual_count, :doc, :type

    def initialize(type, selector, options = {})
      @selector = selector
      @type = type

      @options = case options
                 when Hash
                   options
                 when Numeric
                   {count: options}
                 else
                   {text: options}
                 end
    end

    def doc_for(input)
      engine = type == :xml ? Nokogiri::XML : Nokogiri::HTML

      if input.respond_to?(:body)
        engine.parse(input.body.to_s)
      elsif Nokogiri::XML::Element == input
        input
      else
        engine.parse(input.to_s)
      end
    end

    def matches?(actual, &block)
      @actual = actual
      @doc = doc_for(actual)

      matches = doc.css(selector)

      return options[:count] == 0 if matches.empty?

      matches = filter_on_inner_text(matches) if options[:text]
      matches = filter_on_nested_expectations(matches, block) if block

      @actual_count = matches.size

      return false unless acceptable_count?(actual_count)

      !matches.empty?
    end

    def description
      "have tag #{selector.inspect} with #{options.inspect}"
    end

    def failure_message
      explanation = actual_count ? "but found #{actual_count}" : "but did not"

      "expected\n#{doc}\nto have #{failure_count_phrase} " \
        "#{failure_selector_phrase}, #{explanation}"
    end

    def failure_message_when_negated
      explanation = actual_count ? "but found #{actual_count}" : "but did"

      "expected\n#{doc}\nnot to have " \
        "#{failure_count_phrase} #{failure_selector_phrase}, #{explanation}"
    end

    private def filter_on_inner_text(elements)
      elements.select do |el|
        next(el.inner_text =~ options[:text]) if options[:text].is_a?(Regexp)

        el.inner_text == options[:text]
      end
    end

    private def filter_on_nested_expectations(elements, block)
      elements.select do |el|
        block[el]
      rescue RSpec::Expectations::ExpectationNotMetError
        false
      else
        true
      end
    end

    private def acceptable_count?(count)
      return false if options[:count] && options[:count] != count
      return false if options[:minimum] && count < options[:minimum]
      return false if options[:maximum] && count > options[:maximum]

      true
    end

    private def failure_count_phrase
      if options[:count]
        "#{options[:count]} elements matching"
      elsif options[:minimum] || options[:maximum]
        count_explanations = []
        if options[:minimum]
          count_explanations << "at least #{options[:minimum]}"
        end
        if options[:maximum]
          count_explanations << "at most #{options[:maximum]}"
        end
        "#{count_explanations.join(' and ')} elements matching"
      else
        "an element matching"
      end
    end

    private def failure_selector_phrase
      phrase = selector.inspect
      phrase << (
        options[:text] ? " with inner text #{options[:text].inspect}" : ""
      )
    end
  end
end
