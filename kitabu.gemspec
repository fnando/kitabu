# WARNING : RAKE AUTO-GENERATED FILE. DO NOT MANUALLY EDIT!
# RUN : 'rake gem:update_gemspec'

Gem::Specification.new do |s|
  s.date = "Sun Aug 24 17:34:59 -0300 2008"
  s.executables = ["kitabu"]
  s.authors = ["Nando Vieira"]
  s.required_rubygems_version = ">= 0"
  s.version = "0.2.1"
  s.files = ["Rakefile",
 "kitabu.gemspec",
 "History.txt",
 "License.txt",
 "README.markdown",
 "TODO.txt",
 "app_generators/kitabu",
 "app_generators/kitabu/kitabu_generator.rb",
 "app_generators/kitabu/templates",
 "app_generators/kitabu/templates/config.yml",
 "app_generators/kitabu/templates/css",
 "app_generators/kitabu/templates/css/active4d.css",
 "app_generators/kitabu/templates/css/blackboard.css",
 "app_generators/kitabu/templates/css/dawn.css",
 "app_generators/kitabu/templates/css/eiffel.css",
 "app_generators/kitabu/templates/css/idle.css",
 "app_generators/kitabu/templates/css/iplastic.css",
 "app_generators/kitabu/templates/css/lazy.css",
 "app_generators/kitabu/templates/css/mac_classic.css",
 "app_generators/kitabu/templates/css/slush_poppies.css",
 "app_generators/kitabu/templates/css/sunburst.css",
 "app_generators/kitabu/templates/layouts",
 "app_generators/kitabu/templates/layouts/boom",
 "app_generators/kitabu/templates/layouts/boom/layout.css",
 "app_generators/kitabu/templates/layouts/boom/layout.html",
 "app_generators/kitabu/templates/Rakefile",
 "app_generators/kitabu/templates/user.css",
 "app_generators/kitabu/USAGE",
 "bin/kitabu",
 "lib/kitabu",
 "lib/kitabu/base.rb",
 "lib/kitabu/blackcloth.rb",
 "lib/kitabu/redcloth.rb",
 "lib/kitabu/tasks.rb",
 "lib/kitabu.rb",
 "themes/active4d.css",
 "themes/all_hallows_eve.css",
 "themes/amy.css",
 "themes/blackboard.css",
 "themes/brilliance_black.css",
 "themes/brilliance_dull.css",
 "themes/cobalt.css",
 "themes/dawn.css",
 "themes/eiffel.css",
 "themes/espresso_libre.css",
 "themes/idle.css",
 "themes/iplastic.css",
 "themes/lazy.css",
 "themes/mac_classic.css",
 "themes/magicwb_amiga.css",
 "themes/pastels_on_dark.css",
 "themes/slush_poppies.css",
 "themes/spacecadet.css",
 "themes/sunburst.css",
 "themes/twilight.css",
 "themes/zenburnesque.css"]
  s.has_rdoc = false
  s.requirements = ["Install the Oniguruma RE library and ultraviolet gem to get Syntax Highlighting (only for TextMate users)"]
  s.email = ["fnando.vieira@gmail.com"]
  s.name = "kitabu"
  s.bindir = "bin"
  s.homepage = "http://github.com/fnando/kitabu"
  s.summary = "A framework for creating e-books from Markdown/Textile text markup using Ruby."
  s.description = "A framework for creating e-books from Markdown/Textile text markup using Ruby. Using the Prince PDF generator, you'll be able to get high quality PDFs. Mac users that have Textmate installed can have source code highlighted with his favorite theme."
  s.add_dependency "rubigen", ">= 0"
  s.add_dependency "discount", ">= 0"
  s.add_dependency "hpricot", ">= 0"
  s.add_dependency "unicode", ">= 0"
  s.require_paths = ["lib"]
end