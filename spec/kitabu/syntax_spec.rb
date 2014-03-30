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
    allow(Kitabu::Dependency).to receive_message_chain(:pygments_rb?).and_return(false)
  end

  let(:root) { SPECDIR.join("support/mybook") }

  it "renders inline code" do
    content = Kitabu::Syntax.render(root, :markdown, INLINE)
    expect(content).to have_tag("pre", 1)
    expect(Nokogiri::HTML(content).text).to match(/class Sample/)
  end

  it "renders line range" do
    content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb:3,5 @@@")
    expect(content).to have_tag("pre", 1)
    html = Nokogiri::HTML(content)
    expect(html.text).not_to match(/class HelloWorld/)
    expect(html.text).to match(/def self\.say/)
  end

  it "renders first block by its name" do
    content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb#method @@@")
    expect(content).to have_tag("pre", 1)
    html = Nokogiri::HTML(content)
    expect(html.text).not_to match(/class HelloWorld/)
    expect(html.text).not_to match(/def self\.shout/)
    expect(html.text).to match(/def self\.say/)
  end

  it "renders second block by its name" do
    content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb#another_method @@@")
    expect(content).to have_tag("pre", 1)
    html = Nokogiri::HTML(content)
    expect(html.text).not_to match(/class HelloWorld/)
    expect(html.text).not_to match(/def self\.say/)
    expect(html.text).to match(/def self\.shout/)
  end

  it "renders missing block message" do
    content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb#invalid @@@")
    expect(content).to have_tag("pre", 1)
    html = Nokogiri::HTML(content)
    expect(html.text).not_to match(/class HelloWorld/)
    expect(html.text).not_to match(/def self\.say/)
    expect(html.text).not_to match(/def self\.shout/)
    expect(html.text).to match(/\[missing 'invalid' block name\]/)
  end

  it "renders missing file message" do
    content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby invalid.rb @@@")
    expect(content).to have_tag("pre", 1)
    html = Nokogiri::HTML(content)
    expect(html.text).not_to match(/class HelloWorld/)
    expect(html.text).not_to match(/def self\.say/)
    expect(html.text).not_to match(/def self\.shout/)
    expect(html.text).to match(/\[missing 'code\/invalid.rb' file\]/)
  end

  it "renders file" do
    content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb @@@")
    html = Nokogiri::HTML(content)
    expect(html.text).to match(/class HelloWorld/)
    expect(html.text).to match(/def self\.say/)
  end

  it "adds CodeRay class" do
    expect(Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb @@@")).to have_tag("div.CodeRay", 1)
  end

  it "adds language class" do
    expect(Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb @@@")).to have_tag("div.CodeRay.ruby", 1)
  end

  it "wraps code in pre tag" do
    expect(Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb @@@")).to have_tag("pre", 1)
  end

  it "wraps source in code tag" do
    expect(Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb @@@")).to have_tag("pre > code", 1)
  end

  it "wraps code in notextile tag" do
    expect(Kitabu::Syntax.render(root, :textile, "@@@ ruby code.rb @@@")).to have_tag("notextile", 1)
  end

  it "removes block annotations" do
    content = Kitabu::Syntax.render(root, :markdown, "@@@ ruby code.rb @@@")
    html = Nokogiri::HTML(content)
    expect(html.text).not_to match(/@begin/)
    expect(html.text).not_to match(/@end/)
  end
end
