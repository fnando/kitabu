require "spec_helper"

describe Kitabu::Parser::PDF do
  let(:root) { SPECDIR.join("support/mybook") }

  before do
    Kitabu::Parser::HTML.new(root).parse
    Kitabu::Parser::PDF.new(root).parse
  end

  it "should generate pdf file" do
    root.join("output/mybook.pdf").should be_file
  end
end
