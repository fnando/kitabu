module Kitabu
  class Exporter
    def self.run(root_dir, options)
      exporter = new(root_dir, options)

      if options[:auto]
        exporter.auto! if options[:auto]
      else
        exporter.export!
      end
    end

    attr_accessor :root_dir
    attr_accessor :options

    def initialize(root_dir, options)
      @root_dir = root_dir
      @options = options
    end

    def ui
      @ui ||= Thor::Base.shell.new
    end

    def export!
      helper = root_dir.join("config/helper.rb")
      load(helper) if helper.exist?

      export_html = [nil, "pdf", "html"].include?(options[:only])
      export_pdf = [nil, "pdf"].include?(options[:only])
      export_epub = [nil, "epub"].include?(options[:only])

      Parser::Html.parse(root_dir) if export_html
      Parser::Pdf.parse(root_dir) if export_pdf
      Parser::Epub.parse(root_dir) if export_epub

      if options[:auto]
        message = "exported!"
      else
        message = "** e-book has been exported"
      end

      if options[:open] && export_pdf && RUBY_PLATFORM =~ /darwin/
        filepath = root_dir.join("output/#{File.basename(root_dir)}.pdf")
        IO.popen("open -a Preview.app '#{filepath}'").close
      end

      Notifier.notify(
        :image   => Kitabu::ROOT.join("templates/ebook.png"),
        :title   => "Kitabu",
        :message => "Your \"#{config[:title]}\" e-book has been exported!"
      )
      ui.say message, :green
    end

    def config
      Kitabu.config(root_dir)
    end

    def auto!
      script = Watchr::Script.new

      script.watch(%r[(code|config|images|templates|text)/.*]) do |match|
        ui.say "* #{match[0]}... ", :yellow, false
        export!
      end

      contrl = Watchr::Controller.new(script, Watchr.handler.new)
      contrl.run
    end
  end
end
