require "spec_helper"

describe Kitabu::Parser::Txt, html2text: Kitabu::Dependency.html2text? do
  let(:root) { SPECDIR.join("support/mybook") }

  before do
    Kitabu::Parser::HTML.parse(root)
    Kitabu::Parser::Txt.parse(root)
  end

  it "generates text file" do
    expect(root.join("output/mybook.txt")).to be_file
  end
end
