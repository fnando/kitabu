# -*- encoding: utf-8 -*-
require "spec_helper"

describe Kitabu::Syntax do
  INLINE = <<-CODE
    @@@ ruby
  	class Sample
  	  def hello(name)
  	    puts "hi, #{name}"
  	  end
  	end
  	@@@
	CODE

	let(:root) { SPECDIR.join("support/mybook") }

	it "should render inline code" do
	  content = Kitabu::Syntax.render(root, :markdown, INLINE)
	  content.should have_tag("pre", 1)
	  Nokogiri::HTML(content).text.should match(/class Sample/)
	end

	it "should render line range" do
	  content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb:3,5 @@@")
	  content.should have_tag("pre", 1)
	  html = Nokogiri::HTML(content)
	  html.text.should_not match(/class HelloWorld/)
	  html.text.should match(/def self\.say/)
	end

	it "should render block name" do
	  content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb#method @@@")
	  content.should have_tag("pre", 1)
	  html = Nokogiri::HTML(content)
	  html.text.should_not match(/class HelloWorld/)
	  html.text.should match(/def self\.say/)
	end

	it "should render file" do
	  content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb @@@")
	  html = Nokogiri::HTML(content)
	  html.text.should match(/class HelloWorld/)
	  html.text.should match(/def self\.say/)
	end

	it "should add theme class" do
	  Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb @@@").should have_tag("pre.idle", 1)
	end

	it "should wrap code in pre tag" do
	  Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb @@@").should have_tag("pre", 1)
	end

	it "should wrap code in notextile tag" do
  	Kitabu::Syntax.render(root, :textile, "@@@ ruby code.rb @@@").should have_tag("notextile", 1)
	end

	it "should remove block annotations" do
    content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb @@@")
	  html = Nokogiri::HTML(content)
	  html.text.should_not match(/@begin/)
	  html.text.should_not match(/@end/)
	end
end
