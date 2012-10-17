require "spec_helper"

describe Kitabu::Stats do
  let(:root_dir) { mock("root dir").as_null_object }
  let(:parser) { mock("parser").as_null_object }
  let(:content) { "" }
  subject(:stats) { Kitabu::Stats.new(root_dir) }
  before { stats.stub :content => content }

  context "getting content" do
    it "parses content" do
      Kitabu::Parser::HTML
        .should_receive(:new)
        .with(root_dir)
        .and_return(parser)

      Kitabu::Stats.new(root_dir).content
    end

    it "returns parser content" do
      Kitabu::Parser::HTML.stub :new => parser
      parser.stub :content => "some content"

      expect(Kitabu::Stats.new(root_dir).content).to eql("some content")
    end
  end

  context "words counting" do
    let(:content) { "a b c" }
    it { expect(stats.words).to eql(3) }
  end

  context "chapters counting" do
    let(:content) { "<div class='chapter'/>" * 5 }
    it { expect(stats.chapters).to eql(5) }
  end

  context "images counting" do
    let(:content) { "<img/>" * 2 }
    it { expect(stats.images).to eql(2) }
  end

  context "footnotes counting" do
    let(:content) { "<p class='footnote'/>" * 10 }
    it { expect(stats.footnotes).to eql(10) }
  end

  context "external links counting" do
    let(:content) {
      <<-HTML
        <a href="http://example.org">example.org</a>
        <a href="http://subdomain.example.org">subdomain.example.org</a>
        <a href="#some-anchor">anchor</a>
      HTML
    }

    it { expect(stats.links).to eql(2) }
  end

  context "code blocks" do
    let(:content) { "<pre/>" * 3 }
    it { expect(stats.code_blocks).to eql(3) }
  end
end
