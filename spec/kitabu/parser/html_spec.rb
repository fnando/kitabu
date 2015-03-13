require "spec_helper"

describe Kitabu::Parser::HTML do
  let(:root) { SPECDIR.join("support/mybook") }
  let(:source) { root.join("text") }
  let(:parser) { described_class.new(root) }
  let(:entries) { parser.entries }
  let(:relative) { entries.collect {|e| e.to_s.gsub(/^#{Regexp.escape(source.to_s)}\//, "")} }

  context "when filtering entries" do
    it "skips dot directories" do
      expect(relative).not_to include(".")
      expect(relative).not_to include("..")
    end

    it "skips dot files" do
      expect(relative).not_to include(".gitkeep")
    end

    it "skips files that start with underscore" do
      expect(relative).not_to include("_00_Introduction.markdown")
    end

    it "skips other files" do
      expect(relative).not_to include("CHANGELOG.textile")
      expect(relative).not_to include("TOC.textile")
    end

    it "returns only first-level entries" do
      expect(relative).not_to include("04_With_Directory/Some_Chapter.mkdn")
    end

    it "returns entries" do
      expect(relative.first).to eq("01_Markdown_Chapter.md")
      expect(relative.second).to eq("02_With_Directory")
      expect(relative.third).to be_nil
    end
  end

  context "when generating HTML" do
    let(:file) { SPECDIR.join("support/mybook/output/mybook.html") }
    let(:html) { File.read(file) }
    before { parser.parse }

    it "has several chapters" do
      expect(html).to have_tag("div.chapter", 2)
    end

    it "uses config file" do
      expect(html).to have_tag("div.imprint p", "Copyright (C) 2010 John Doe.")
    end

    it "renders changelog" do
      expect(html).to have_tag("div.changelog h2", "Revisions")
    end
  end
end
