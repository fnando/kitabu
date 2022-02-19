# frozen_string_literal: true

require "spec_helper"

describe Kitabu::Exporter::Mobi, calibre: Kitabu::Dependency.calibre? do
  it "generates mobi" do
    root = SPECDIR.join("support/mybook")

    Kitabu::Exporter::HTML.export(root)
    Kitabu::Exporter::Epub.export(root)
    Kitabu::Exporter::Mobi.export(root)

    expect(root.join("output/mybook.mobi")).to be_file
  end
end
