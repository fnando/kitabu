# frozen_string_literal: false

require "spec_helper"

describe Kitabu::Exporter::Mobi, kindlegen: Kitabu::Dependency.kindlegen? do
  it "generates mobi" do
    root = SPECDIR.join("support/mybook")

    Kitabu::Exporter::HTML.export(root)
    Kitabu::Exporter::Mobi.export(root)

    expect(root.join("output/mybook.mobi")).to be_file
  end
end
