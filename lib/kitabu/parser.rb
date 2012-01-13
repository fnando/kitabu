module Kitabu
  module Parser
    autoload :Html  , "kitabu/parser/html"
    autoload :Pdf   , "kitabu/parser/pdf"
    autoload :Epub  , "kitabu/parser/epub"
    autoload :Mobi  , "kitabu/parser/mobi"

    class Base
      # The e-book directory.
      #
      attr_accessor :root_dir

      # Where the text files are stored.
      #
      attr_accessor :source

      def self.parse(root_dir)
        new(root_dir).parse
      end

      def initialize(root_dir)
        @root_dir = Pathname.new(root_dir)
        @source = root_dir.join("text")
      end

      # Return directory's basename.
      #
      def name
        File.basename(root_dir)
      end
    end
  end
end
