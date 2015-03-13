require "spec_helper"

describe Kitabu::Parser::Mobi do
  let(:root) { SPECDIR.join("support/mybook") }

  before do
    Kitabu::Parser::HTML.parse(root)
    Kitabu::Parser::Mobi.parse(root)
  end

  it "generates mobi" do
    expect(root.join("output/mybook.mobi")).to be_file
  end
end
