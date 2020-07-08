# frozen_string_literal: false

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
end
