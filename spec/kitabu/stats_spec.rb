# frozen_string_literal: true

require "spec_helper"

describe Kitabu::Stats do
  let(:root_dir) { double("root dir").as_null_object }
  let(:format) { double("format").as_null_object }
  let(:content) { "" }
  subject(:stats) { Kitabu::Stats.new(root_dir) }

  before do
    allow(stats).to receive_message_chain(:content).and_return(content)
  end

  context "getting content" do
    it "generates content" do
      expect(Kitabu::Exporter::HTML)
        .to receive(:new)
        .with(root_dir)
        .and_return(format)

      Kitabu::Stats.new(root_dir).content
    end

    it "returns content" do
      allow(Kitabu::Exporter::HTML).to receive_message_chain(:new)
        .and_return(format)
      allow(format).to receive_message_chain(:content)
        .and_return("some content")

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
    let(:content) { "<div class='footnotes'>#{'<li></li>' * 10}</div>" }
    it { expect(stats.footnotes).to eql(10) }
  end

  context "external links counting" do
    let(:content) do
      <<-HTML
        <a href="http://example.org">example.org</a>
        <a href="http://subdomain.example.org">subdomain.example.org</a>
        <a href="#some-anchor">anchor</a>
      HTML
    end

    it { expect(stats.links).to eql(2) }
  end

  context "code blocks" do
    let(:content) { "<pre/>" * 3 }
    it { expect(stats.code_blocks).to eql(3) }
  end
end
