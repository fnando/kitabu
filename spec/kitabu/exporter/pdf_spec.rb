# frozen_string_literal: true

require "spec_helper"

describe Kitabu::Exporter::PDF, prince: Kitabu::Dependency.prince? do
  let(:root) { SPECDIR.join("support/mybook") }

  before do
    Kitabu::Exporter::HTML.new(root).export
    Kitabu::Exporter::PDF.new(root).export
  end

  it "creates html with css identifier" do
    expect(root.join("output/mybook.pdf.html").read).to have_tag("body.pdf")
    expect(root.join("output/mybook.print.html").read).to have_tag("body.print")
  end

  it "sets stylesheet for print pdf" do
    selector = 'link[rel=stylesheet][href="styles/print.css"]'
    expect(root.join("output/mybook.print.html").read).to have_tag(selector)
  end

  it "sets stylesheet for pdf" do
    selector = 'link[rel=stylesheet][href="styles/pdf.css"]'
    expect(root.join("output/mybook.pdf.html").read).to have_tag(selector)
  end

  it "generates pdf file for print" do
    expect(root.join("output/mybook.print.pdf")).to be_file
  end

  it "generates pdf file" do
    expect(root.join("output/mybook.pdf")).to be_file
  end
end
