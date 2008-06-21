Gem::Specification.new do |s|
  s.name = %q{bookmaker}
  s.version = "0.0.7"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nando Vieira"]
  s.date = %q{2008-06-21}
  s.default_executable = %q{bookmaker}
  s.description = %q{A framework for creating e-books from Markdown/Textile text markup using Ruby. Using the Prince PDF generator, you'll be able to get high quality PDFs. Mac users that have Textmate installed can have source code highlighted with his favorite theme.}
  s.email = ["fnando.vieira@gmail.com"]
  s.executables = ["bookmaker"]
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "PostInstall.txt", "TODO.txt"]
  s.files = ["History.txt", "License.txt", "Manifest.txt", "PostInstall.txt", "README.markdown", "TODO.txt", "Rakefile", "app_generators/bookmaker/bookmaker_generator.rb", "app_generators/bookmaker/templates/config.yml", "app_generators/bookmaker/templates/Rakefile", "app_generators/bookmaker/templates/user.css", "app_generators/bookmaker/templates/layouts/boom/layout.html", "app_generators/bookmaker/templates/layouts/boom/layout.css", "app_generators/bookmaker/templates/css/active4d.css", "app_generators/bookmaker/templates/css/blackboard.css", "app_generators/bookmaker/templates/css/dawn.css", "app_generators/bookmaker/templates/css/eiffel.css", "app_generators/bookmaker/templates/css/idle.css", "app_generators/bookmaker/templates/css/iplastic.css", "app_generators/bookmaker/templates/css/lazy.css", "app_generators/bookmaker/templates/css/mac_classic.css", "app_generators/bookmaker/templates/css/slush_poppies.css", "app_generators/bookmaker/templates/css/sunburst.css", "bin/bookmaker", "config/hoe.rb", "config/requirements.rb", "lib/bookmaker.rb", "lib/bookmaker/version.rb", "lib/bookmaker/base.rb", "lib/bookmaker/tasks.rb", "lib/bookmaker/blackcloth.rb", "script/console", "script/destroy", "script/generate", "script/txt2html", "setup.rb", "test/test_bookmaker.rb", "test/test_helper.rb", "test/test_bookmaker_generator.rb", "test/test_generator_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/fnando/bookmaker}
  s.post_install_message = %q{}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{bookmaker}
  s.rubygems_version = %q{1.1.1}
  s.summary = %q{A framework for creating e-books from Markdown/Textile text markup using Ruby. Using the Prince PDF generator, you'll be able to get high quality PDFs. Mac users that have Textmate installed can have source code highlighted with his favorite theme.}
  s.test_files = ["test/test_bookmaker.rb", "test/test_bookmaker_generator.rb", "test/test_generator_helper.rb", "test/test_helper.rb"]
end
