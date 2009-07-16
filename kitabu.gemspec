# WARNING : RAKE AUTO-GENERATED FILE. DO NOT MANUALLY EDIT!
# RUN : 'rake gem:update_gemspec'

Gem::Specification.new do |s|
  s.required_rubygems_version = ">= 0"
  s.has_rdoc = true
  s.email = ["fnando.vieira@gmail.com"]
  s.name = "kitabu"
  s.homepage = "http://github.com/fnando/kitabu"
  s.bindir = "bin"
  s.executables = ["kitabu"]
  s.summary = "A framework for creating e-books from Markdown/Textile text markup using Ruby."
  s.requirements = ["Install the Oniguruma RE library and ultraviolet gem to get Syntax Highlighting (only for TextMate users)"]
  s.description = "A framework for creating e-books from Markdown/Textile text markup using Ruby. Using the Prince PDF generator, you'll be able to get high quality PDFs. Mac users that have Textmate installed can have source code highlighted with his favorite theme."
  s.add_dependency "discount", ">= 0"
  s.add_dependency "hpricot", ">= 0"
  s.add_dependency "unicode", ">= 0"
  s.add_dependency "main", ">= 0"
  s.version = "0.3.1"
  s.require_paths = ["lib"]
  s.files = ["Rakefile",
 "kitabu.gemspec",
 "README.markdown",
 "bin/kitabu",
 "lib/kitabu",
 "lib/kitabu/base.rb",
 "lib/kitabu/blackcloth.rb",
 "lib/kitabu/redcloth.rb",
 "lib/kitabu/tasks.rb",
 "lib/kitabu/templates.rb",
 "lib/kitabu.rb",
 "templates/config.yml",
 "templates/layouts",
 "templates/layouts/boom",
 "templates/layouts/boom/layout.css",
 "templates/layouts/boom/layout.html",
 "templates/Rakefile",
 "templates/syntax.css",
 "templates/themes",
 "templates/themes/active4d.css",
 "templates/themes/blackboard.css",
 "templates/themes/dawn.css",
 "templates/themes/eiffel.css",
 "templates/themes/idle.css",
 "templates/themes/iplastic.css",
 "templates/themes/lazy.css",
 "templates/themes/mac_classic.css",
 "templates/themes/slush_poppies.css",
 "templates/themes/sunburst.css",
 "templates/user.css"]
  s.authors = ["Nando Vieira"]
end