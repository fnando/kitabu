module RedCloth
  INLINE_FORMATTERS = [:textile, :footnote, :link]

  def self.convert(text)
    new(text).to_html(*INLINE_FORMATTERS)
  end

  module Inline
    FN_RE = /
      (\s+)?    # getting spaces
      %\{       # opening
      (.*?)     # footnote
      \}#       # closing
    /xm

    def footnote(text)
      text.gsub!(FN_RE) do |m|
        %(<span class="footnote">#{$2}</span>)
      end
    end

    LINK_RE = /
      <
      ((?:https?|ftp):\/\/.*?)
      >
    /xm

    def link(text)
      text.gsub!(LINK_RE) do |m|
        %(<a href="#{$1}">#{$1}</a>)
      end
    end
  end

  module Formatters
    module HTML
      def figure(options = {})
        %[<p class="figure"><img src="../images/#{options[:text]}" alt="#{options[:class]}" /><br/><span class="caption">#{options[:class]}</span></p>]
      end

      def note(options = {})
        %[<p class="note">#{options[:text]}</p>]
      end

      def attention(options = {})
        %[<p class="attention">#{options[:text]}</p>]
      end

      def file(options = {})
        base_url = Kitabu.config[:base_url]

        if base_url
          url = File.join(base_url, options[:text])
        else
          url = content
          $stderr << "\nYou're using `file. #{content}` but didn't set base_url in your configuration file.\n"
        end

        %[<p class="file"><span><strong>Download</strong> <a href="#{url}">#{options[:text]}</a></span></p>]
      end
    end
  end
end

RedCloth.send(:include, RedCloth::Inline)
