module Matchers
  def have_tag(selector, options = {}, &block)
    HaveTag.new(:html, selector, options, &block)
  end

  def have_node(selector, options = {}, &block)
    HaveTag.new(:xml, selector, options, &block)
  end

  class HaveTag
    attr_reader :options, :selector, :actual, :actual_count, :doc, :type

    def initialize(type, selector, options = {}, &block)
      @selector = selector
      @type = type

      case options
      when Hash
        @options = options
      when Numeric
        @options = {:count => options}
      else
        @options = {:text => options}
      end
    end

    def doc_for(input)
      engine = type == :xml ? Nokogiri::XML : Nokogiri::HTML

      if input.respond_to?(:body)
        engine.parse(input.body.to_s)
      elsif Nokogiri::XML::Element === input
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

      return false if not acceptable_count?(actual_count)

      !matches.empty?
    end

    def description
      "have tag #{selector.inspect} with #{options.inspect}"
    end

    def failure_message
      explanation = actual_count ? "but found #{actual_count}" : "but did not"
      "expected\n#{doc.to_s}\nto have #{failure_count_phrase} #{failure_selector_phrase}, #{explanation}"
    end

    def negative_failure_message
      explanation = actual_count ? "but found #{actual_count}" : "but did"
      "expected\n#{doc.to_s}\nnot to have #{failure_count_phrase} #{failure_selector_phrase}, #{explanation}"
    end

    private
    def filter_on_inner_text(elements)
      elements.select do |el|
        next(el.inner_text =~ options[:text]) if options[:text].is_a?(Regexp)
        el.inner_text == options[:text]
      end
    end

    def filter_on_nested_expectations(elements, block)
      elements.select do |el|
        begin
          block[el]
        rescue RSpec::Expectations::ExpectationNotMetError
          false
        else
          true
        end
      end
    end

    def acceptable_count?(count)
      return false unless options[:count] === count if options[:count]
      return false unless count >= options[:minimum] if options[:minimum]
      return false unless count <= options[:maximum] if options[:maximum]
      true
    end

    def failure_count_phrase
      if options[:count]
        "#{options[:count]} elements matching"
      elsif options[:minimum] || options[:maximum]
        count_explanations = []
        count_explanations << "at least #{options[:minimum]}" if options[:minimum]
        count_explanations << "at most #{options[:maximum]}"  if options[:maximum]
        "#{count_explanations.join(' and ')} elements matching"
      else
        "an element matching"
      end
    end

    def failure_selector_phrase
      phrase = selector.inspect
      phrase << (options[:text] ? " with inner text #{options[:text].inspect}" : "")
    end
  end
end
