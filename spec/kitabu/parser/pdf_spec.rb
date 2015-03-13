require "spec_helper"

describe Kitabu::Parser::PDF do
  let(:root) { SPECDIR.join("support/mybook") }

  before do
    Kitabu::Parser::HTML.new(root).parse
    Kitabu::Parser::PDF.new(root).parse
  end

  it "creates html with css identifier" do
    expect(root.join("output/mybook.pdf.html").read).to have_tag('html.pdf')
    expect(root.join("output/mybook.print.html").read).to have_tag('html.print')
  end

  it "sets stylesheet for print pdf" do
    expect(root.join("output/mybook.print.html").read).to have_tag('link[rel=stylesheet][href="styles/print.css"]')
  end

  it "sets stylesheet for pdf" do
    expect(root.join("output/mybook.pdf.html").read).to have_tag('link[rel=stylesheet][href="styles/pdf.css"]')
  end

  it "generates pdf file for print" do
    expect(root.join("output/mybook.print.pdf")).to be_file
  end

  it "generates pdf file" do
    expect(root.join("output/mybook.pdf")).to be_file
  end
end
