# frozen_string_literal: true

module Kitabu
  class FrontMatter
    REGEX = /^---\n(?<yml>.*?)\n---\n+/m
    Result = Struct.new(:content, :meta, keyword_init: true)

    def self.parse(raw)
      content = strip_lines(raw)
      matches = content.match(REGEX)
      result = Result.new(meta: {}, content:)

      return result unless matches
      return result unless content.index(matches[:yml]) >= 0

      meta = YAML.safe_load(matches[:yml])
      matter_size = matches[0].lines.size
      content = content.lines[matter_size..-1].join

      Result.new(meta:, content: "#{content.strip}\n")
    end

    def self.strip_lines(raw)
      lines = []
      saw_content = false

      raw.lines.each do |line|
        saw_content = line.strip != "" if saw_content == false
        lines << line if saw_content
      end

      lines.join
    end
  end
end
