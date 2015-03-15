require "spec_helper"

describe Kitabu::Exporter::Mobi, kindlegen: Kitabu::Dependency.kindlegen? do
  let(:root) { SPECDIR.join("support/mybook") }

  before do
    Kitabu::Exporter::HTML.export(root)
    Kitabu::Exporter::Mobi.export(root)
  end

  it "generates mobi" do
    expect(root.join("output/mybook.mobi")).to be_file
  end
end
