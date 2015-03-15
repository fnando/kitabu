require "spec_helper"

describe Kitabu::Exporter::HTML do
  let(:root) { SPECDIR.join("support/mybook") }
  let(:format) { described_class.new(root) }

  context "when generating HTML" do
    let(:file) { SPECDIR.join("support/mybook/output/mybook.html") }
    let(:html) { File.read(file) }
    before { format.export }

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
