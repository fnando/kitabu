module Kitabu
  class Exporter
    class CSS < Base
      attr_reader :root_dir

      def export
        files = Dir[root_dir.join("templates/styles/*.{scss,sass}").to_s]
        options = {
          style: :expanded,
          line_numbers: true,
          load_paths: [root_dir.join("templates/styles")]
        }

        files.each do |file|
          _, file_name, syntax = *File.basename(file).match(/(.*?)\.(.*?)$/)
          engine = Sass::Engine.new(File.read(file), options.merge(syntax: syntax.to_sym))
          target = root_dir.join("output/styles", "#{file_name}.css")
          FileUtils.mkdir_p(File.dirname(target))
          File.open(target, "w") {|io| io << engine.render }
        end
      end
    end
  end
end
