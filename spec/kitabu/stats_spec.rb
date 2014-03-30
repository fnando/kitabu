require "spec_helper"

describe Kitabu::Stats do
  let(:root_dir) { double("root dir").as_null_object }
  let(:parser) { double("parser").as_null_object }
  let(:content) { "" }
  subject(:stats) { Kitabu::Stats.new(root_dir) }

  before {
    allow(stats).to receive_message_chain(:content).and_return(content)
  }

  context "getting content" do
    it "parses content" do
      expect(Kitabu::Parser::HTML)
        .to receive(:new)
        .with(root_dir)
        .and_return(parser)

      Kitabu::Stats.new(root_dir).content
    end

    it "returns parser content" do
      allow(Kitabu::Parser::HTML).to receive_message_chain(:new).and_return(parser)
      allow(parser).to receive_message_chain(:content).and_return("some content")

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
