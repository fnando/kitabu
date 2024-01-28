# frozen_string_literal: true

module Kitabu
  class CSS
    def self.create_file(root_dir:, config:)
      buffer = StringIO.new
      buffer << accent_color(config:)
      buffer << "\n\n"
      buffer << syntax_highlight(config:)
      buffer << "\n\n"
      buffer << translations(config:)

      support_dir = root_dir.join("assets/styles/support")

      FileUtils.mkdir_p(support_dir)
      support_dir.join("kitabu.css").open("w") do |file|
        file << buffer.tap(&:rewind).read
      end
    end

    def self.accent_color(config:)
      accent_color = config.fetch(:css_accent_color, "#000")

      <<~CSS
        :root {
          --accent-color: #{accent_color};
        }
      CSS
    end

    def self.syntax_highlight(config:)
      Rouge::Theme.find(
        config.fetch(:syntax_highlight_theme, :github)
      ).render(scope: ".highlight")
    end

    def self.translations(config:)
      backend = I18n.backend.translations

      translations =
        backend.each_with_object([]) do |(lang, dict), buffer|
          buffer << "html[lang='#{lang}'] {"

          dict.each do |key, value|
            next unless value.is_a?(String) && value.lines.count == 1

            buffer << "--#{key.to_s.tr('_', '-')}-text: #{value.inspect};"
          end

          buffer << "}\n"
        end

      translations.join("\n")
    end
  end
end
