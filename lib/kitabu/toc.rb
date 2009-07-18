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

      @toc << %(<ul class="level#{@current_level}">) if @current_level > @previous_level
      @toc << %(</li></ul>) * (@previous_level - @current_level) if @current_level < @previous_level
      @toc << %(</li>) if @current_level <= @previous_level
      @toc << %(<li>)
    end

    def tag_end(name)
      return unless header?(name)
      @in_header = false
      @previous_level = @current_level
    end

    def text(str)
      return unless in_header?
      @toc << %(<a href="##{@id}"><span>#{str}</span></a>)
    end

    def method_missing(*args)
    end

    def to_s
      @toc + (%(</li></ul>) * (@stack.last - 1))
    rescue
      ""
    end
  end
end