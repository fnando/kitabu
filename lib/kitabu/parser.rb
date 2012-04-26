require 'open3'

module Kitabu
  module Parser
    autoload :Html  , "kitabu/parser/html"
    autoload :Pdf   , "kitabu/parser/pdf"
    autoload :Epub  , "kitabu/parser/epub"
    autoload :Mobi  , "kitabu/parser/mobi"
    autoload :Txt   , "kitabu/parser/txt"

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

      def spawn_command(cmd)
        begin
          stdout_and_stderr, status = Open3.capture2e *cmd
        rescue Errno::ENOENT => e
          puts e.message
        else
          if ! status.success?
            puts stdout_and_stderr
          end

          status.success?
        end
      end
    end
  end
end
