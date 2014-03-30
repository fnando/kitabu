require "spec_helper"

describe Kitabu::Parser::PDF do
  let(:root) { SPECDIR.join("support/mybook") }

  before do
    Kitabu::Parser::HTML.new(root).parse
    Kitabu::Parser::PDF.new(root).parse
  end

  it "generates pdf file" do
    expect(root.join("output/mybook.pdf")).to be_file
  end
end
