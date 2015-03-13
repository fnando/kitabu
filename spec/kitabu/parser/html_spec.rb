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
      expect(relative).not_to include("_00_Introduction.md")
    end

    it "skips other files" do
      expect(relative).not_to include("CHANGELOG.md")
      expect(relative).not_to include("TOC.md")
    end

    it "returns only first-level entries" do
      expect(relative).not_to include("03_With_Directory/Some_Chapter.md")
    end

    it "returns entries" do
      expect(relative.first).to eq("01_Markdown_Chapter.md")
      expect(relative.second).to eq("02_ERB_Chapter.md.erb")
      expect(relative.third).to eq("03_With_Directory")
      expect(relative.fourth).to be_nil
    end
  end

  context "when generating HTML" do
    let(:file) { SPECDIR.join("support/mybook/output/mybook.html") }
    let(:html) { File.read(file) }
    before { parser.parse }

    it "keeps html file around" do
      expect(file).to be_file
    end

    it "has several chapters" do
      expect(html).to have_tag("div.chapter", 3)
    end

    it "uses config file" do
      expect(html).to have_tag("div.imprint p", "Copyright (C) 2010 John Doe.")
    end

    it "renders changelog" do
      expect(html).to have_tag("div.changelog h2", "Revisions")
    end

    it "renders erb" do
      expect(html).to have_tag("h2", "ERB")
    end

    it "renders erb blocks" do
      expect(html).to have_tag("div.note.info > p", "This is a note!")
    end
  end
end
