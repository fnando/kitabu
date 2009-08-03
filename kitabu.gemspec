# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{kitabu}
  s.version = "0.3.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nando Vieira"]
  s.date = %q{2009-08-03}
  s.default_executable = %q{kitabu}
  s.description = %q{A framework for creating e-books from Markdown/Textile text markup using Ruby. 
Using the Prince PDF generator, you'll be able to get high quality PDFs.
}
  s.email = %q{fnando.vieira@gmail.com}
  s.executables = ["kitabu"]
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "README.markdown",
     "Rakefile",
     "VERSION",
     "bin/kitabu",
     "kitabu.gemspec",
     "lib/kitabu.rb",
     "lib/kitabu/base.rb",
     "lib/kitabu/blackcloth.rb",
     "lib/kitabu/markup.rb",
     "lib/kitabu/redcloth.rb",
     "lib/kitabu/tasks.rb",
     "lib/kitabu/templates.rb",
     "lib/kitabu/toc.rb",
     "templates/Rakefile",
     "templates/config.yml",
     "templates/layouts/boom/layout.css",
     "templates/layouts/boom/layout.html",
     "templates/syntax.css",
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
     "templates/user.css"
  ]
  s.homepage = %q{http://fnando.github.com/kitabu.html}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.requirements = ["Install the Oniguruma RE library", "Install colorize using gem install fnando-colorize -s http://gems.github.com"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A framework for creating e-books from Markdown/Textile text markup using Ruby.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<discount>, [">= 0"])
      s.add_runtime_dependency(%q<hpricot>, [">= 0"])
      s.add_runtime_dependency(%q<unicode>, [">= 0"])
      s.add_runtime_dependency(%q<main>, [">= 0"])
      s.add_runtime_dependency(%q<ultraviolet>, [">= 0"])
      s.add_runtime_dependency(%q<colorize>, [">= 0"])
    else
      s.add_dependency(%q<discount>, [">= 0"])
      s.add_dependency(%q<hpricot>, [">= 0"])
      s.add_dependency(%q<unicode>, [">= 0"])
      s.add_dependency(%q<main>, [">= 0"])
      s.add_dependency(%q<ultraviolet>, [">= 0"])
      s.add_dependency(%q<colorize>, [">= 0"])
    end
  else
    s.add_dependency(%q<discount>, [">= 0"])
    s.add_dependency(%q<hpricot>, [">= 0"])
    s.add_dependency(%q<unicode>, [">= 0"])
    s.add_dependency(%q<main>, [">= 0"])
    s.add_dependency(%q<ultraviolet>, [">= 0"])
    s.add_dependency(%q<colorize>, [">= 0"])
  end
end
