require "spec_helper"

describe Kitabu::Exporter::Txt, html2text: Kitabu::Dependency.html2text? do
  let(:root) { SPECDIR.join("support/mybook") }

  before do
    Kitabu::Exporter::HTML.export(root)
    Kitabu::Exporter::Txt.export(root)
  end

  it "generates text file" do
    expect(root.join("output/mybook.txt")).to be_file
  end
end
