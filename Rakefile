require 'rake'

PKG_FILES = %w( Rakefile kitabu.gemspec History.txt License.txt README.markdown TODO.txt ) + Dir["{app_generators,bin,lib,themes}/**/*"]

spec = Gem::Specification.new do |s|
  s.name = "kitabu"
  s.version = "0.2.1"
  s.summary = "A framework for creating e-books from Markdown/Textile text markup using Ruby."
  s.authors = ["Nando Vieira"]
  s.email = ["fnando.vieira@gmail.com"]
  s.homepage = "http://github.com/fnando/kitabu"
  s.description = "A framework for creating e-books from Markdown/Textile text markup using Ruby. Using the Prince PDF generator, you'll be able to get high quality PDFs. Mac users that have Textmate installed can have source code highlighted with his favorite theme."
  s.has_rdoc = false
  s.files = PKG_FILES
	s.bindir = "bin"
	s.executables = "kitabu"
	
	# Dependencies
  s.add_dependency "rubigen"
  s.add_dependency "discount"
  s.add_dependency "hpricot"
  s.add_dependency "unicode"
  # Requirements
  s.requirements << "Install the Oniguruma RE library and ultraviolet gem to get Syntax Highlighting (only for TextMate users)"
end

namespace :gem do
  # Thanks to the Merb project for this code.
  desc "Update Github Gemspec"
    task :update_gemspec do
      skip_fields = %w(new_platform original_platform specification_version loaded required_ruby_version rubygems_version platform )
      
      result = "# WARNING : RAKE AUTO-GENERATED FILE. DO NOT MANUALLY EDIT!\n"
      result << "# RUN : 'rake gem:update_gemspec'\n\n"
      result << "Gem::Specification.new do |s|\n"
      
      spec.instance_variables.each do |ivar|
        value = spec.instance_variable_get(ivar)
        name  = ivar.split("@").last
        value = Time.now if name == "date"
        
        next if skip_fields.include?(name) || value.nil? || value == "" || (value.respond_to?(:empty?) && value.empty?)
        if name == "dependencies"
          value.each do |d|
            dep, *ver = d.to_s.split(" ")
            result <<  "  s.add_dependency #{dep.inspect}, #{ver.join(" ").inspect.gsub(/[()]/, "").gsub(", runtime", "")}\n"
          end
        else
          case value
          when Array
            value =  name != "files" ? value.inspect : value.inspect.split(",").join(",\n")
          when FalseClass
          when TrueClass
          when Fixnum
          when String
            value = value.inspect
          else
            value = value.to_s.inspect
          end
          result << "  s.#{name} = #{value}\n"
        end
      end
      
      result << "end"
      File.open(File.join(File.dirname(__FILE__), "#{spec.name}.gemspec"), "w"){|f| f << result}
    end

end