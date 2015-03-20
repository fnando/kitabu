module Kitabu
  class Exporter
    def self.run(root_dir, options)
      exporter = new(root_dir, options)
      exporter.export!
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

      FileUtils.rm_rf root_dir.join("output").to_s

      export_pdf = [nil, "pdf"].include?(options[:only])
      export_epub = [nil, "mobi", "epub"].include?(options[:only])
      export_mobi = [nil, "mobi"].include?(options[:only])
      export_txt = [nil, "txt"].include?(options[:only])

      exported = []
      exported << HTML.export(root_dir)
      exported << PDF.export(root_dir) if export_pdf && Dependency.prince?
      exported << Epub.export(root_dir) if export_epub
      exported << Mobi.export(root_dir) if export_mobi && Dependency.kindlegen?
      exported << Txt.export(root_dir) if export_txt && Dependency.html2text?

      if exported.all?
        color = :green
        message = options[:auto] ? "exported!" : "** e-book has been exported"

        if options[:open] && export_pdf
          filepath = root_dir.join("output/#{File.basename(root_dir)}.pdf")

          if RUBY_PLATFORM =~ /darwin/
            IO.popen("open -a Preview.app '#{filepath}'").close
          elsif RUBY_PLATFORM =~ /linux/
            Process.detach(Process.spawn("xdg-open '#{filepath}'", :out => "/dev/null"))
          end
        end

        Notifier.notify(
          :image   => Kitabu::ROOT.join("templates/ebook.png").to_s,
          :title   => "Kitabu",
          :message => "Your \"#{config[:title]}\" e-book has been exported!"
        )
      else
        color = :red
        message = options[:auto] ? "could not be exported!" : "** e-book couldn't be exported"
      end

      ui.say message, color
    end

    def config
      Kitabu.config(root_dir)
    end
  end
end
