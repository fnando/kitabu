require "spec_helper"

describe Kitabu::Parser::Pdf do
  let(:root) { SPECDIR.join("support/mybook") }

  before do
    Kitabu::Parser::Html.new(root).parse
    Kitabu::Parser::Pdf.new(root).parse
  end

  it "should generate pdf file" do
    root.join("output/mybook.pdf").should be_file
  end
end
