module Kitabu
  class Markdown
    # Supported Markdown libraries
    #
    MARKDOWN_LIBRARIES = %w[Maruku BlueCloth PEGMarkdown Redcarpet RDiscount]

    # Retrieve preferred Markdown processor.
    # You'll need one of the following libraries:
    #
    # # RDiscount: https://rubygems.org/gems/rdiscount
    # # Maruku: https://rubygems.org/gems/maruku
    # # PEGMarkdown: https://rubygems.org/gems/rpeg-markdown
    # # BlueCloth: https://rubygems.org/gems/bluecloth
    # # Redcarpet: https://rubygems.org/gems/redcarpet
    #
    # Note: RDiscount will always be installed as Kitabu's dependency but only used when no
    # alternative library is available.
    #
    def self.engine
      @engine ||= Object.const_get(MARKDOWN_LIBRARIES.find {|lib| Object.const_defined?(lib)})
    end

    # Convert Markdown to HTML.
    def self.to_html(content)
      case engine.name
      when "Redcarpet"
        render = Redcarpet::Render::HTML.new(:hard_wrap => true, :xhtml => true)
        Redcarpet::Markdown.new(render).render(content)
      else
        engine.new(content).to_html
      end
    end
  end
end
