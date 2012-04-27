require "spec_helper"

describe Kitabu::Parser::Epub do
  let(:root) { SPECDIR.join("support/mybook") }

  before do
    Kitabu::Parser::HTML.parse(root)
    Kitabu::Parser::Epub.parse(root)
  end

  it "generates e-pub" do
    root.join("output/mybook.epub").should be_file
  end
end
