module Kitabu
  # The Kitabu::Generator class will create a new book structure.
  #
  #   ebook = Kitabu::Generator.new
  #   ebook.destination_root = "/some/path/book-name"
  #   ebook.invoke_all
  #
  class Generator < Thor::Group
    include Thor::Actions

    desc "Generate a new e-Book structure"

    def self.source_root
      File.dirname(__FILE__) + "/../../templates"
    end

    def copy_template_files
      copy_file "layout.erb"  , "templates/html/layout.erb"
      copy_file "layout.css"  , "templates/html/layout.css"
      copy_file "user.css"    , "templates/html/user.css"
      copy_file "syntax.css"  , "templates/html/syntax.css"
      copy_file "cover.erb"   , "templates/epub/cover.erb"
      copy_file "epub.css"    , "templates/epub/style.css"
      copy_file "epub.erb"    , "templates/epub/page.erb"
    end

    def copy_config_file
      @name = full_name
      @uid = Digest::MD5.hexdigest("#{Time.now}--#{rand}")
      @year = Date.today.year
      template "config.erb", "config/kitabu.yml"
    end

    def copy_helper_file
      copy_file "helper.rb", "config/helper.rb"
    end

    def create_directories
      empty_directory "output"
      empty_directory "images"
      empty_directory "text"
      empty_directory "code"
    end

    def create_git_files
      create_file ".gitignore" do
        "output/*.{html,epub,pdf}\n"
      end

      create_file "output/.gitkeep"
      create_file "images/.gitkeep"
      create_file "text/.gitkeep"
      create_file "code/.gitkeep"
    end

    private
    # Retrieve user's name using finger.
    # Defaults to <tt>John Doe</tt>.
    #
    def full_name
      name = `finger $USER 2> /dev/null | grep Login | colrm 1 46`.chomp
      name.present? ? name.squish : "John Doe"
    end
  end
end
