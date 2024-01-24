# frozen_string_literal: true

require "spec_helper"

describe Kitabu::Exporter::Epub do
  let(:root) { SPECDIR.join("support/mybook") }

  it "generates e-pub" do
    Kitabu::Exporter::HTML.export(root)
    Kitabu::Exporter::Epub.export(root)

    expect(root.join("output/mybook.epub")).to be_file
  end
end
