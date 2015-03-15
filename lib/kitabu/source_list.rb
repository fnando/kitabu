module Kitabu
  class SourceList
    # List of directories that should be skipped.
    #
    IGNORE_DIR = %w[. .. .svn .git]

    # Files that should be skipped.
    #
    IGNORE_FILES = /^(CHANGELOG|TOC)\..*?$/

    # List of recognized extensions.
    #
    EXTENSIONS = %w[md erb]

    attr_reader :root_dir
    attr_reader :source

    def initialize(root_dir)
      @root_dir = root_dir
      @source = root_dir.join('text')
    end

    #
    #
    def each_chapter(&block)
      files_grouped_by_chapter.each(&block)
    end

    def files_grouped_by_chapter
      entries.each_with_object([]) do |entry, buffer|
        files = chapter_files(entry)
        buffer << files unless files.empty?
      end
    end

    def chapter_files(entry)
      # Chapters can be files outside a directory.
      if File.file?(entry)
        [entry]
      else
        Dir["#{entry}/**/*.{#{EXTENSIONS.join(",")}}"].sort
      end
    end

    # Return a list of all recognized files.
    #
    def entries
      Dir.entries(source).sort.each_with_object([]) do |entry, buffer|
        buffer << source.join(entry) if valid_entry?(entry)
      end
    end

    # Check if path is a valid entry.
    # Files/directories that start with a dot or underscore will be skipped.
    #
    def valid_entry?(entry)
      entry !~ /^(\.|_)/ && (valid_directory?(entry) || valid_file?(entry))
    end

    # Check if path is a valid directory.
    #
    def valid_directory?(entry)
      File.directory?(source.join(entry)) && !IGNORE_DIR.include?(File.basename(entry))
    end

    # Check if path is a valid file.
    #
    def valid_file?(entry)
      ext = File.extname(entry).gsub(/\./, "").downcase
      File.file?(source.join(entry)) && EXTENSIONS.include?(ext) && entry !~ IGNORE_FILES
    end
  end
end
