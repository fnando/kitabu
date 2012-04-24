module Kitabu
  class Syntax
    attr_reader :io
    attr_reader :lines
    attr_reader :root_dir
    attr_reader :format

    # Render syntax blocks from specified source code.
    #
    #   dir = Pathname.new(File.dirname(__FILE__))
    #   text = File.read(dir.join("text/some_file.textile"))
    #   Kitabu::Syntax.render(dir, :textile, text)
    #
    def self.render(root_dir, format, source_code, raw = false)
      source_code.gsub(/@@@(.*?)@@@/m) do |match|
        new(root_dir, format, $1, raw).process
      end
    end

    # Process each syntax block individually.
    #
    def initialize(root_dir, format, code, raw = false)
      @format = format
      @root_dir = root_dir
      @io = StringIO.new(code)
      @lines = io.readlines.collect(&:chomp)
      @language = 'text' if raw
    end

    # Return unprocessed line codes.
    #
    def raw
      lines[1..-1].join("\n")
    end

    # Return meta data from syntax annotation.
    #
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

    # Process syntax block, returning a +pre+ HTML tag.
    #
    def process
      code = raw.to_s.strip_heredoc
      code = process_file.gsub(/\n^.*?@(begin|end):.*?$/, "") if meta[:file]

      code = Pygments.highlight(code, :lexer => language)

      # escape for textile
      code = %[<notextile>#{code}</notextile>] if format == :textile
      code
    end

    private
    # Process line range as in <tt>@@@ ruby some_file.rb:15,20 @@@</tt>.
    #
    def process_range(code)
      starts, ends = meta[:reference].split(",").collect(&:to_i)
      code = StringIO.new(code).readlines[starts-1..ends-1].join("\n").strip_heredoc.chomp
    end

    # Process block name as in <tt>@@@ ruby some_file.rb#some_block @@@</tt>.
    #
    def process_block(code)
      code.gsub!(/\r\n/, "\n")
      re = %r[@begin: *\b(#{meta[:reference]})\b *[^\n]*\n(.*?)\n[^\n]*@end: \1]im

      if code.match(re)
        $2.strip_heredoc
      else
        "[missing '#{meta[:reference]}' block name]"
      end
    end

    # Process file and its relatives.
    #
    def process_file
      file_path = root_dir.join("code/#{meta[:file]}")

      if File.exist?(file_path)
        code = File.read(file_path)

        if meta[:type] == :range
          process_range(code)
        elsif meta[:type] == :block
          process_block(code)
        else
          code
        end
      else
        "[missing 'code/#{meta[:file]}' file]"
      end
    end

    # Return e-book's configuration.
    #
    def config
      Kitabu.config(root_dir)
    end    
    
    # Return the language used for this syntax block. Overrideable
    # for epub generation.
    def language
      @language || meta[:language]
    end
  end
end
