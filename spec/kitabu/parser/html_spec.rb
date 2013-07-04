require "spec_helper"

describe Kitabu::Parser::HTML do
  let(:root) { SPECDIR.join("support/mybook") }
  let(:source) { root.join("text") }
  let(:parser) { described_class.new(root) }
  let(:entries) { parser.entries }
  let(:relative) { entries.collect {|e| e.to_s.gsub(/^#{Regexp.escape(source.to_s)}\//, "")} }

  context "when filtering entries" do
    it "skips dot directories" do
      relative.should_not include(".")
      relative.should_not include("..")
    end

    it "skips dot files" do
      relative.should_not include(".gitkeep")
    end

    it "skips files that start with underscore" do
      relative.should_not include("_00_Introduction.markdown")
    end

    it "skips other files" do
      relative.should_not include("CHANGELOG.textile")
      relative.should_not include("TOC.textile")
    end

    it "returns only first-level entries" do
      relative.should_not include("04_With_Directory/Some_Chapter.mkdn")
    end

    it "returns entries" do
      relative.first.should == "01_Markdown_Chapter.markdown"
      relative.second.should == "02_Textile_Chapter.textile"
      relative.third.should == "03_HTML_Chapter.html"
      relative.fourth.should == "04_With_Directory"
      relative.fifth.should == "11_Markdown_Chapter_Template.md.erb"
      relative[5].should be_nil
    end
  end

  context "when generating HTML" do
    let(:file) { SPECDIR.join("support/mybook/output/mybook.html") }
    let(:html) { File.read(file) }
    before { parser.parse }

    it "has several chapters" do
      html.should have_tag("div.chapter", 5)
    end

    it "renders .markdown" do
      html.should have_tag("div.chapter > h2#markdown", "Markdown")
    end

    it "renders .mkdn" do
      html.should have_tag("div.chapter > h2#some-chapter", "Some Chapter")
    end

    it "renders .erb" do
      html.should have_tag("div.chapter > h2#erb", "ERB")
    end

    it "renders .erb inside directory" do
      html.should have_tag("div > h3#yet-another-paragraph", "Yet Another Paragraph")
    end

    it "renders .textile" do
      html.should have_tag("div.chapter > h2#textile", "Textile")
    end

    it "renders .html" do
      html.should have_tag("div.chapter > h2#html", "HTML")
    end

    it "uses config file" do
      html.should have_tag("div.imprint p", "Copyright (C) 2010 John Doe.")
    end

    it "renders changelog" do
      html.should have_tag("div.changelog h2", "Revisions")
    end
  end
end
