module Kitabu
  class Toc
    include REXML::StreamListener

    private_class_method :new
    attr_reader :buffer
    attr_reader :toc
    attr_reader :attrs
    attr_accessor :content

    def self.normalize(content)
      counter = {}
      html = Nokogiri::HTML.parse(content)
      html.search("h2, h3, h4, h5, h6").each do |tag|
        title = tag.inner_text
        permalink = title.to_permalink

        counter[permalink] ||= 0
        counter[permalink] += 1

        permalink = "#{permalink}-#{counter[permalink]}" if counter[permalink] > 1

        tag.set_attribute("id", permalink)
      end

      _, content = *html.to_xhtml.match(/<body>(.*?)<\/body>/xm)
      content
    end

    def self.generate(content)
      content = normalize(content)
      streamer = new
      streamer.content = content
      io = StringIO.new(content)
      REXML::Document.parse_stream(io, streamer)
      streamer
    end

    def initialize
      @buffer = ""
      @attrs = {}
      @toc = []
      @counters = {}
    end

    def in_header?
      @in_header
    end

    def header?(tag)
      tag =~ /h[2-6]/i
    end

    def tag_start(name, attrs)
      return unless header?(name)
      @in_header = true
      @attrs = attrs
    end

    def text(string)
      return unless in_header?
      @buffer << string
    end

    def tag_end(name)
      return unless header?(name)

      toc << {
        :level     => name.gsub(/[^\d]/, "").to_i,
        :text      => buffer,
        :permalink => attrs["id"]
      }

      reset!
    end

    def reset!
      @current_tag = nil
      @in_header = false
      @buffer = ""
    end

    def to_hash
      {
        :content => content,
        :html => to_html,
        :toc => toc
      }
    end

    def to_html
      String.new.tap do |html|
        toc.each do |options|
          html << %[<div class="level#{options[:level]} #{options[:permalink]}"><a href="##{options[:permalink]}"><span>#{options[:text]}</span></a></div>]
        end
      end
    end
  end
end