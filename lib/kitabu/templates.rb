module Kitabu
  module Templates
    TEMPLATES_ROOT = File.join(Kitabu::Base::GEM_ROOT, 'templates')
    DIRECTORIES = %w(text templates output)
    
    def self.process!(options)
      directories!(options)
      bundle_css!(options)
      files!(options)
      config!(options)
    end
    
    def self.directories!(options)
      FileUtils.mkdir(options[:path])
      
      DIRECTORIES.each do |d|
        FileUtils.mkdir File.join(options[:path], d)
      end
    end
    
    def self.files!(options)
      copy_file "Rakefile", "#{options[:path]}/Rakefile"
      copy_file "layouts/#{options[:layout]}/layout.css", "#{options[:path]}/templates/layout.css"
      copy_file "layouts/#{options[:layout]}/layout.html", "#{options[:path]}/templates/layout.html"
      copy_file "user.css", "#{options[:path]}/templates/user.css"
    end
    
    def self.config!(options)
      template = File.new(File.join(TEMPLATES_ROOT, 'config.yml')).read
      env = OpenStruct.new(options)
      contents = ERB.new(template).result env.instance_eval{binding}

      File.open(File.join(options[:path], 'config.yml'), 'w+') << contents
    end
    
    def self.bundle_css!(options)
      contents = Dir["#{TEMPLATES_ROOT}/themes/*.css"].collect do |file|
        File.read(file)
      end

      File.open("#{options[:path]}/templates/syntax.css", "w+") << contents.join("\n\n")
    end
    
    private
      def self.copy_file(from, to)
        FileUtils.cp File.join(TEMPLATES_ROOT, from), to
      end
  end
end