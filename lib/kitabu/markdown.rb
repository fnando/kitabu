# frozen_string_literal: true

module Kitabu
  module Markdown
    class Renderer < Redcarpet::Render::HTML
      include Redcarpet::Render::SmartyPants
      include Rouge::Plugins::Redcarpet

      # Be more flexible than github and support any arbitrary name.
      ALERT_MARK = /^\[!(?<type>[A-Z]+)\]$/

      # Support alert boxes just like github.
      # https://github.com/orgs/community/discussions/16925
      def block_quote(quote)
        html = Nokogiri::HTML(quote)
        element = html.css("body > :first-child").first

        matches = element.text.match(ALERT_MARK)

        return "<blockquote>#{quote}</blockquote>" unless matches

        element.remove

        type = matches[:type].downcase
        type = "info" if type == "note"

        title = I18n.t(
          type,
          scope: :notes,
          default: type.titleize
        )

        <<~HTML.strip_heredoc
          <div class="note #{type}">
            <p class="note--title">#{title}</p>
            #{html.css('body').inner_html}
          </div>
        HTML
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
