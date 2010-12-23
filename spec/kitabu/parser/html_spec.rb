require "spec_helper"

describe Kitabu::Parser::Html do
  let(:root) { SPECDIR.join("support/mybook") }
  let(:source) { root.join("text") }
  let(:parser) { Kitabu::Parser::Html.new(root) }
  let(:entries) { parser.entries }
  let(:relative) { entries.collect {|e| e.to_s.gsub(/^#{Regexp.escape(source.to_s)}\//, "")} }

  context "when filtering entries" do
    it "should skip dot directories" do
      relative.should_not include(".")
      relative.should_not include("..")
    end

    it "should skip dot files" do
      relative.should_not include(".gitkeep")
    end

    it "should skip files that start with underscore" do
      relative.should_not include("_00_Introduction.markdown")
    end

    it "should return only first-level entries" do
      relative.should_not include("05_With_Directory/Some_Chapter.mkdn")
    end

    it "should return entries" do
      relative.first.should == "01_Markdown_Chapter.markdown"
      relative.second.should == "02_Textile_Chapter.textile"
      relative.third.should == "03_RDoc_Chapter.rdoc"
      relative.fourth.should == "04_HTML_Chapter.html"
      relative.fifth.should == "05_With_Directory"
      relative[5].should be_nil
    end
  end

  context "when generating HTML" do
    let(:file) { SPECDIR.join("support/mybook/output/mybook.html") }
    let(:html) { File.read(file) }
    before { parser.parse }

    it "should have several chapters" do
      html.should have_tag("div.chapter", 5)
    end

    it "should render .markdown" do
      html.should have_tag("div.chapter > h2#markdown", "Markdown")
    end

    it "should render .mkdn" do
      html.should have_tag("div.chapter > h2#some-chapter", "Some Chapter")
    end

    it "should render .textile" do
      html.should have_tag("div.chapter > h2#textile", "Textile")
    end

    it "should render .html" do
      html.should have_tag("div.chapter > h2#html", "HTML")
    end

    it "should render .rdoc" do
      html.should have_tag("div.chapter > h2#rdoc", "RDoc")
    end

    it "should have use config file" do
      html.should have_tag("div.imprint p", "Copyright (C) 2010 John Doe.")
    end
  end
end
