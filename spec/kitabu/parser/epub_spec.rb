require "spec_helper"

describe Kitabu::Parser::Epub do
  let(:root) { SPECDIR.join("support/mybook") }

  it "should generate e-pub" do
    Kitabu::Parser::Epub.parse(root)
    root.join("output/mybook.epub").should be_file
  end
end
