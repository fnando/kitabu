module Kitabu
  module Parser
    class Html < Base
      # Supported Markdown libraries
      #
      MARKDOWN_LIBRARIES = %w[Maruku BlueCloth PEGMarkdown Redcarpet RDiscount]

      # List of directories that should be skipped.
      #
      IGNORE_DIR = %w[. .. .svn]

      # Files that should be skipped.
      #
      IGNORE_FILES = /^(CHANGELOG|TOC)\..*?$/

      # List of recognized extensions.
      #
      EXTENSIONS = %w[md mkdn markdown textile html]

      # Parse all files and save the parsed content
      # to <tt>output/book_name.html</tt>.
      #
      def parse
        File.open(root_dir.join("output/#{name}.html"), "w+") do |file|
          file << parse_layout(content)
        end
        true
      rescue Exception
        false
      end

      # Return all chapters wrapped in a <tt>div.chapter</tt> tag.
      #
      def content
        String.new.tap do |chapters|
          entries.each do |entry|
            files = chapter_files(entry)

            # no markup files, so skip to the next one!
            next if files.empty?

            chapters << %[<div class="chapter">#{render_chapter(files)}</div>]
          end
        end
      end

      # Return the configuration file.
      #
      def config
        Kitabu.config(root_dir)
      end

      # Return a list of all recognized files.
      #
      def entries
        Dir.entries(source).sort.inject([]) do |buffer, entry|
          buffer << source.join(entry) if valid_entry?(entry)
          buffer
        end
      end

      private
      def chapter_files(entry)
        # Chapters can be files outside a directory.
        if File.file?(entry)
          [entry]
        else
          Dir.glob("#{entry}/**/*.{#{EXTENSIONS.join(",")}}").sort
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

      # Render +file+ considering its extension.
      #
      def render_file(file, plain_syntax = false)
        file_format = format(file)

        content = Kitabu::Syntax.render(root_dir, file_format, File.read(file), plain_syntax)

        case file_format
        when :markdown
          markdown.new(content).to_html
        when :textile
          RedCloth.convert(content)
        else
          content
        end
      end

      def format(file)
        case File.extname(file).downcase
        when ".markdown", ".mkdn", ".md"
          :markdown
        when ".textile"
          :textile
        else
          :html
        end
      end

      # Parse layout file, making available all configuration entries.
      #
      def parse_layout(html)
        toc = Toc.generate(html)
        locals = config.merge({
          :content   => toc.content,
          :toc       => toc.to_html,
          :changelog => render_changelog
        })
        render_template(root_dir.join("templates/html/layout.erb"), locals)
      end

      # Render changelog file.
      # This file can be used to inform any book change.
      #
      def render_changelog
        changelog = Dir[root_dir.join("text/CHANGELOG.*")].first
        return render_file(changelog) if changelog
        nil
      end

      # Render a eRb template using +locals+ as data seed.
      #
      def render_template(file, locals = {})
        ERB.new(File.read(file)).result OpenStruct.new(locals).instance_eval{ binding }
      end

      # Render all +files+ from a given chapter.
      #
      def render_chapter(files, plain_syntax = false)
        String.new.tap do |chapter|
          files.each do |file|
            chapter << render_file(file, plain_syntax) << "\n\n"
          end
        end
      end

      # Retrieve preferred Markdown processor.
      # You'll need one of the following libraries:
      #
      # # RDiscount: https://rubygems.org/gems/rdiscount
      # # Maruku: https://rubygems.org/gems/maruku
      # # PEGMarkdown: https://rubygems.org/gems/rpeg-markdown
      # # BlueCloth: https://rubygems.org/gems/bluecloth
      # # Redcarpet: https://rubygems.org/gems/redcarpet
      #
      # Note: RDiscount will always be installed as Kitabu's dependency but only used when no
      # alternative library is available.
      #
      def markdown
        @markdown ||= Object.const_get(MARKDOWN_LIBRARIES.find {|lib| Object.const_defined?(lib)})
      end
    end
  end
end
