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

  before do
    Kitabu::Dependency.stub :pygments_rb? => false
  end

  let(:root) { SPECDIR.join("support/mybook") }

  it "renders inline code" do
    content = Kitabu::Syntax.render(root, :markdown, INLINE)
    content.should have_tag("pre", 1)
    Nokogiri::HTML(content).text.should match(/class Sample/)
  end

  it "renders line range" do
    content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb:3,5 @@@")
    content.should have_tag("pre", 1)
    html = Nokogiri::HTML(content)
    html.text.should_not match(/class HelloWorld/)
    html.text.should match(/def self\.say/)
  end

  it "renders first block by its name" do
    content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb#method @@@")
    content.should have_tag("pre", 1)
    html = Nokogiri::HTML(content)
    html.text.should_not match(/class HelloWorld/)
    html.text.should_not match(/def self\.shout/)
    html.text.should match(/def self\.say/)
  end

  it "renders second block by its name" do
    content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb#another_method @@@")
    content.should have_tag("pre", 1)
    html = Nokogiri::HTML(content)
    html.text.should_not match(/class HelloWorld/)
    html.text.should_not match(/def self\.say/)
    html.text.should match(/def self\.shout/)
  end

  it "renders missing block message" do
    content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb#invalid @@@")
    content.should have_tag("pre", 1)
    html = Nokogiri::HTML(content)
    html.text.should_not match(/class HelloWorld/)
    html.text.should_not match(/def self\.say/)
    html.text.should_not match(/def self\.shout/)
    html.text.should match(/\[missing 'invalid' block name\]/)
  end

  it "renders missing file message" do
    content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby invalid.rb @@@")
    content.should have_tag("pre", 1)
    html = Nokogiri::HTML(content)
    html.text.should_not match(/class HelloWorld/)
    html.text.should_not match(/def self\.say/)
    html.text.should_not match(/def self\.shout/)
    html.text.should match(/\[missing 'code\/invalid.rb' file\]/)
  end

  it "renders file" do
    content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb @@@")
    html = Nokogiri::HTML(content)
    html.text.should match(/class HelloWorld/)
    html.text.should match(/def self\.say/)
  end

  it "adds CodeRay class" do
    Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb @@@").should have_tag("div.CodeRay", 1)
  end

  it "adds language class" do
    Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb @@@").should have_tag("div.CodeRay.ruby", 1)
  end

  it "wraps code in pre tag" do
    Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb @@@").should have_tag("pre", 1)
  end

  it "wraps source in code tag" do
    Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb @@@").should have_tag("pre > code", 1)
  end

  it "wraps code in notextile tag" do
    Kitabu::Syntax.render(root, :textile, "@@@ ruby code.rb @@@").should have_tag("notextile", 1)
  end

  it "removes block annotations" do
    content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb @@@")
    html = Nokogiri::HTML(content)
    html.text.should_not match(/@begin/)
    html.text.should_not match(/@end/)
  end
end
