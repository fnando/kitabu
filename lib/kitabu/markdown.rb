# frozen_string_literal: true

module Kitabu
  module Markdown
    # N.B.: Redcarpet pass down escaped HTML. There's no need to escape the
    # content and we can just interpolate it.
    class Renderer < Redcarpet::Render::HTML
      include Redcarpet::Render::SmartyPants
      include Rouge::Plugins::Redcarpet
      using Extensions

      # Be more flexible than github and support any arbitrary name.
      ALERT_MARK = /^\[!(?<type>[A-Z]+)\](?<title>.*?)?$/

      HEADING_ID = /^(?<text>.*?)(?: {#(?<id>.*?)})?$/

      def escape(text)
        Nokogiri::HTML.fragment(text).text
      end

      def heading_counter
        @heading_counter ||= Hash.new {|h, k| h[k] = 0 }
      end

      def header(text, level)
        matches = text.strip.match(HEADING_ID)
        title = matches[:text].strip
        html = Nokogiri::HTML.fragment("<h#{level}>#{title}</h#{level}>")
        heading = html.first_element_child
        title = heading.text

        id = matches[:id]
        id ||= title.to_permalink

        heading_counter[id] += 1
        id = "#{id}-#{heading_counter[id]}" if heading_counter[id] > 1

        heading.add_child %[<a class="anchor" href="##{id}" aria-hidden="true" tabindex="-1"></a>] # rubocop:disable Style/LineLength
        heading.set_attribute :tabindex, "-1"
        heading.set_attribute(:id, id)

        heading.to_s
      end

      # Support alert boxes just like github.
      # https://github.com/orgs/community/discussions/16925
      def block_quote(quote)
        html = Nokogiri::HTML.fragment(quote)
        element = html.children.first

        matches = element.text.match(ALERT_MARK)

        return "<blockquote>#{quote}</blockquote>" unless matches

        element.remove

        type = matches[:type].downcase

        title = matches[:title].strip

        if title == ""
          title = I18n.t(type, scope: :alerts, default: type.titleize)
        end

        html = Nokogiri::HTML.fragment <<~HTML.strip_heredoc
          <div class="alert-message #{type}">
            <p class="alert-message--title"></p>
            #{html}
          </div>
        HTML

        html.css(".alert-message--title").first.content = title

        html.to_s
      end

      def table_cell(content, alignment, header)
        tag = header ? "th" : "td"

        html = Nokogiri::HTML.fragment("<#{tag}>#{content}</#{tag}>")
        node = html.children.first
        node.append_class("align-#{alignment}") if alignment

        html.to_s
      end

      def table(header, body)
        <<~HTML
          <table class="table">
            <thead>
              #{header}
            </thead>
            <tbody>
              #{body}
            </tbody>
          </table>
        HTML
      end

      def image(src, title, alt)
        html = Nokogiri::HTML.fragment("<img />")
        img = html.css("img").first
        img.set_attribute(:src, src)
        img.set_attribute(:srcset, "#{src} 2x")
        img.set_attribute(:alt, alt)
        img.set_attribute(:title, title) if title

        return html.to_s unless title

        html = Nokogiri::HTML.fragment <<~HTML
          <figure>
            #{img}
            <figcaption></figcaption>
          </figure>
        HTML

        html.css("figcaption").first.content = title

        html.to_s
      end
    end

    class << self
      # Set markdown renderer
      attr_accessor :processor

      # Set the default markdown renderer's options.
      attr_accessor :default_renderer_options

      # Set the default markdown options.
      attr_accessor :default_markdown_options
    end

    # We can't use `safe_links_only` because otherwise images with relative path
    # won't be rendered.
    #
    # https://github.com/vmg/redcarpet/issues/554
    self.default_renderer_options = {hard_wrap: false, safe_links_only: false}

    self.default_markdown_options = {
      tables: true,
      footnotes: true,
      space_after_headers: true,
      superscript: true,
      highlight: true,
      strikethrough: true,
      autolink: true,
      fenced_code_blocks: true,
      no_intra_emphasis: true
    }

    renderer = Renderer.new(default_renderer_options)

    self.processor = Redcarpet::Markdown.new(renderer, default_markdown_options)

    def self.render(text)
      text = run_hooks(:before_render, text)
      run_hooks(:after_render, processor.render(text))
    end

    # Hook up and run custom code before certain actions. Existing hooks:
    #
    # * before_render
    # * after_render
    #
    # To add a new hook:
    #
    #   Kitabu::Markdown.add_hook(:before_render) do |content|
    #     content
    #   end
    #
    def self.hooks
      @hooks ||= Hash.new {|h, k| h[k] = [] }
    end

    def self.add_hook(name, &block)
      hooks[name.to_sym] << block
    end

    def self.run_hooks(name, arg)
      hooks[name.to_sym].reduce(arg) {|buffer, hook| hook.call(buffer) }
    end

    def self.setup_default_hooks
      add_hook(:after_render) do |content|
        content.gsub(Unicode::Emoji::REGEX) do |emoji|
          %[<span class="emoji">#{emoji}</span>]
        end
      end
    end

    setup_default_hooks
  end
end
