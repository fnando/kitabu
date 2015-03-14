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

    def copy_templates
      directory "templates", "templates"
    end

    def copy_sample_texts
      directory "text", "text"
    end

    def copy_images
      directory "images", "images"
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

    def copy_gemfile
      copy_file "Gemfile"
    end

    def create_directories
      empty_directory "output"
    end

    def create_git_files
      create_file ".gitignore" do
        "/output"
      end
    end

    def copy_guardfile
      copy_file "Guardfile"
    end

    def bundle_install
      inside destination_root do
        run "bundle install"
      end
    end

    private
    # Retrieve user's name using finger.
    # Defaults to <tt>John Doe</tt>.
    #
    def full_name
      name = `finger $USER 2> /dev/null | grep Login | colrm 1 46 2> /dev/null`.chomp
      name.present? ? name.squish : "John Doe"
    end
  end
end
