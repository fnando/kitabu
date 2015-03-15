require 'spec_helper'

describe Kitabu::Exporter::CSS do
  let(:root) { SPECDIR.join("support/mybook") }

  before do
    Kitabu::Exporter::CSS.export(root)
  end

  it "generates css files" do
    expect(root.join("output/styles/epub.css")).to be_file
    expect(root.join("output/styles/pdf.css")).to be_file
    expect(root.join("output/styles/print.css")).to be_file
    expect(root.join("output/styles/html.css")).to be_file
  end
end
