# frozen_string_literal: false

module Kitabu
  module Markdown
    class Renderer < Redcarpet::Render::HTML
      include Redcarpet::Render::SmartyPants
      include Rouge::Plugins::Redcarpet
    end

    class << self
      # Set markdown renderer
      attr_accessor :processor
    end

    renderer = Renderer.new(hard_wrap: true, safe_links_only: true)

    self.processor = Redcarpet::Markdown.new(renderer, {
                                               tables: true,
                                               footnotes: true,
                                               space_after_headers: true,
                                               superscript: true,
                                               highlight: true,
                                               strikethrough: true,
                                               autolink: true,
                                               fenced_code_blocks: true,
                                               no_intra_emphasis: true
                                             })

    def self.render(text)
      processor.render(text)
    end
  end
end
