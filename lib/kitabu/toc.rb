module Kitabu
  class Toc
    include REXML::StreamListener

    def initialize
      @toc = ""
      @previous_level = 0
      @tag = nil
      @stack = []
    end

    def header?(tag=nil)
      tag ||= @tag_name
      return false unless tag.to_s =~ /h[2-6]/
      @tag_name = tag
      return true
    end

    def in_header?
      @in_header
    end

    def tag_start(name, attrs)
      @tag_name = name
      return unless header?(name)
      @in_header = true
      @current_level = name.gsub!(/[^2-6]/, '').to_i
      @stack << @current_level
      @id = attrs["id"]
    end

    def tag_end(name)
      return unless header?(name)
      @in_header = false
      @previous_level = @current_level
    end

    def text(str)
      return unless in_header?
      @toc << %(<div class="level#{@current_level} #{@id}"><a href="##{@id}"><span>#{str}</span></a></div>)
    end

    def method_missing(*args)
    end

    def to_s
      @toc
    end
  end
end