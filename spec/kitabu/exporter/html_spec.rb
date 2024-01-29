# frozen_string_literal: true

require "spec_helper"

describe Kitabu::Exporter::HTML do
  let(:root) { SPECDIR.join("support/mybook") }
  let(:format) { described_class.new(root) }

  context "when generating HTML" do
    let(:file) { SPECDIR.join("support/mybook/output/mybook.html") }
    let(:html) { File.read(file) }
    before { format.export }

    it "generates valid markup", osx: Kitabu::Dependency.macos? do
      `./vendor/bin/tidy5_osx '#{file}' 2>&1 > /dev/null`
      expect($CHILD_STATUS.exitstatus).to eq(0)
    end

    it "generates valid markup", linux: Kitabu::Dependency.linux? do
      `./vendor/bin/tidy5_linux '#{file}' 2>&1 > /dev/null`
      expect($CHILD_STATUS.exitstatus).to eq(0)
    end

    it "keeps html file around" do
      expect(file).to be_file
    end

    it "has several chapters" do
      expect(html).to have_tag("section.chapter", 3)
    end

    it "uses config file" do
      expect(html).to have_tag("section.imprint p",
                               "Copyright (C) 2010 John Doe.")
    end

    it "renders changelog" do
      expect(html).to have_tag("section.changelog h2", "Revisions")
    end

    it "renders erb" do
      expect(html).to have_tag("h2", "ERB")
    end

    it "renders erb blocks" do
      expect(html).to have_tag("div.note.info > p", "This is a note!")
    end

    it "wraps emojis" do
      expect(html).to have_tag("span.emoji", "🫠")
      expect(html).to have_tag("span.emoji", "👋")
    end

    it "copies assets" do
      expect(root.join("output/assets/images/cover.png")).to be_file
      expect(root.join("output/assets/images/logo.gif")).to be_file
      expect(root.join("output/assets/fonts/OpenSans-CondBold.ttf")).to be_file
      expect(root.join("output/assets/styles/epub.css")).to be_file
      expect(root.join("output/assets/styles/html.css")).to be_file
      expect(root.join("output/assets/styles/pdf.css")).to be_file
      expect(root.join("output/assets/styles/print.css")).to be_file
      expect(root.join("output/assets/scripts")).to be_directory
    end
  end
end
