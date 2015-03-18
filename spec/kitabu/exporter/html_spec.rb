require "spec_helper"

describe Kitabu::Exporter::HTML do
  let(:root) { SPECDIR.join("support/mybook") }
  let(:format) { described_class.new(root) }

  context "when generating HTML" do
    let(:file) { SPECDIR.join("support/mybook/output/mybook.html") }
    let(:html) { File.read(file) }
    before { format.export }

    it "generates valid markup", osx: RUBY_PLATFORM.include?('darwin') do
      `./vendor/bin/tidy5_osx '#{file}' 2>&1 > /dev/null`
      expect($?.exitstatus).to eq(0)
    end

    it "generates valid markup", linux: RUBY_PLATFORM.include?('linux') do
      `./vendor/bin/tidy5_linux '#{file}' 2>&1 > /dev/null`
      expect($?.exitstatus).to eq(0)
    end

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

    it "copies fonts" do
      expect(root.join('output/fonts/OpenSans-CondBold.ttf')).to be_file
    end

    it "exports css files" do
      expect(root.join('output/styles/epub.css')).to be_file
      expect(root.join('output/styles/html.css')).to be_file
      expect(root.join('output/styles/pdf.css')).to be_file
      expect(root.join('output/styles/print.css')).to be_file
    end
  end
end
