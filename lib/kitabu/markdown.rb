# frozen_string_literal: true

module Kitabu
  module Markdown
    class Renderer < Redcarpet::Render::HTML
      include Redcarpet::Render::SmartyPants
      include Rouge::Plugins::Redcarpet
    end

    class << self
      # Set markdown renderer
      attr_accessor :processor

      # Set the default markdown renderer's options.
      attr_accessor :default_renderer_options

      # Set the default markdown options.
      attr_accessor :default_markdown_options
    end

    self.default_renderer_options = {hard_wrap: false, safe_links_only: true}

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
      processor.render(text)
    end
  end
end
