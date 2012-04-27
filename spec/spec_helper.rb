require "kitabu"
require "pathname"
require "test_notifier/runner/rspec"

SPECDIR = Pathname.new(File.dirname(__FILE__))
TMPDIR = SPECDIR.join("tmp")

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|r| require r}

RSpec.configure do |config|
  config.include(SpecHelper)
  config.include(Matchers)

  cleaner = proc do
    [
      TMPDIR,
      SPECDIR.join("support/mybook/output/mybook.pdf"),
      SPECDIR.join("support/mybook/output/mybook.epub"),
      SPECDIR.join("support/mybook/output/mybook.html")
    ].each do |i|
      FileUtils.rm_rf(i) if File.exist?(i)
    end
  end

  config.before(&cleaner)
  config.after(&cleaner)
  config.before { FileUtils.mkdir_p(TMPDIR) }
end
