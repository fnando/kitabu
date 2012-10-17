module Kitabu
  class Stats
    attr_reader :root_dir

    def initialize(root_dir)
      @root_dir = root_dir
    end

    def text
      @text ||= html.text
    end

    def html
      @html ||= Nokogiri::HTML(content)
    end

    def words
      @words ||= text.split(" ").size
    end

    def chapters
      @chapters ||= html.css(".chapter").size
    end

    def images
      @images ||= html.css("img").size
    end

    def footnotes
      @footnotes ||= html.css("p.footnote").size
    end

    def links
      @links ||= html.css("[href^='http']").size
    end

    def code_blocks
      @code_blocks ||= html.css("pre").size
    end

    def content
      @content ||= Parser::HTML.new(root_dir).content
    end
  end
end
