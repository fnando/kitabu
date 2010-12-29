module Kitabu
  class Syntax
    # include Ink::Helper

    attr_reader :io
    attr_reader :lines
    attr_reader :root_dir
    attr_reader :format

    def self.render(root_dir, format, source)
      source.gsub(/@@@(.*?)@@@/m) do |match|
        new(root_dir, format, $1).process
      end
    end

    def initialize(root_dir, format, code)
      @format = format
      @root_dir = root_dir
      @io = StringIO.new(code)
      @lines = io.readlines.collect(&:chomp)
    end

    def raw
      lines[1..-1].join("\n")
    end

    def meta
      @meta ||= begin
        line = lines.first.squish
        _, language, file, modifier, reference = *line.match(/^([^ ]+)(?: ([^:#]+)(?:(:|#)(.*?))?)?$/)

        if modifier == "#"
          type = :block
        elsif modifier == ":"
          type = :range
        elsif file
          type = :file
        else
          type = :inline
        end

        {
          :language  => language,
          :file      => file,
          :type      => type,
          :reference => reference
        }
      end
    end

    def process
      code = raw.to_s.strip_heredoc
      file_path = root_dir.join("code/#{meta[:file]}")

      if meta[:file] && File.exist?(file_path)
        code = File.read(file_path)

        if meta[:type] == :range
          starts, ends = meta[:reference].split(",").collect(&:to_i)
          code = StringIO.new(code).readlines[starts-1..ends-1].join("\n").strip_heredoc.chomp
        elsif meta[:type] == :block
          code.gsub!(/\r\n/, "\n")
          re = %r[@begin: *\b#{meta[:block]}\b *[^\n]*\n(.*?)\n[^\n]*@end: \b#{meta[:block]}\b]im
          code = $1.strip_heredoc if code.match(re)
        end

        # remove block annotations
        code.gsub!(/\n^.*?@(begin|end):.*?$/, "")
      end

      if meta[:language] == "text"
        code.gsub!(/</, "&lt;")
        code = %[<pre class="#{config[:theme]}"><code>#{code}</code></pre>]
      else
        silence_warnings do
          code = Uv.parse(code, "xhtml", meta[:language], false, config[:theme])
        end
      end

      # escape for textile
      code = %[<notextile>#{code}</notextile>] if format == :textile

      code
    end

    def config
      Kitabu.config(root_dir)
    end
  end
end
