# frozen_string_literal: true

require "spec_helper"

describe Kitabu::Exporter::Epub do
  let(:root) { SPECDIR.join("support/mybook") }

  before do
    Kitabu::Exporter::HTML.export(root)
    Kitabu::Exporter::Epub.export(root)
  end

  it "generates e-pub" do
    expect(root.join("output/mybook.epub")).to be_file
  end

  it "adds leading zero to 1 digit number" do
    sections = root.join("output/epub").glob("section*.{xhtml,html}")
    sections = sections.map do |path|
      path.to_s.split("/").last
    end
    expected = 1.upto(12).map {|i| "section_#{i.to_s.rjust(2, '0')}.html" }
    expect(sections).to eq(expected)
  end
end
