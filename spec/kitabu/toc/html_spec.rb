# -*- encoding: utf-8 -*-
require "spec_helper"

describe Kitabu::TOC::HTML do
  def regexp(text)
    /#{Regexp.escape(text)}/
  end

  HTML = <<-HTML
    <h1>Item 1</h1>
    <h2>Item 1.2</h2>
    <h3>Item 1.1.3</h3>
    <h4>Item 1.1.1.4</h4>
    <h5>Item 1.1.1.1.5</h5>
    <h6>Item 1.1.1.1.1.6</h6>

    <h2>Item 2.1</h2>
    <h2>Item 2.1 again</h2>
    <h2>Internacionalização</h2>
  HTML

  HTML.force_encoding("utf-8")

  let(:toc) { described_class.generate(HTML) }
  let(:html) { toc.to_html }
  let(:content) { toc.content }

  it "has no body tag" do
    expect(content).not_to match(/<body>/)
  end

  it "generates toc" do
    expect(html).to have_tag("div.level1.item-1", regexp("Item 1"))
    expect(html).to have_tag("div.level2.item-1-2", regexp("Item 1.2"))
    expect(html).to have_tag("div.level3.item-1-1-3", regexp("Item 1.1.3"))
    expect(html).to have_tag("div.level4.item-1-1-1-4", regexp("Item 1.1.1.4"))
    expect(html).to have_tag("div.level5.item-1-1-1-1-5", regexp("Item 1.1.1.1.5"))
    expect(html).to have_tag("div.level6.item-1-1-1-1-1-6", regexp("Item 1.1.1.1.1.6"))

    expect(html).to have_tag("div.level2.item-2-1", regexp("Item 2.1"))
    expect(html).to have_tag("div.level2.item-2-1-again", regexp("Item 2.1 again"))

    expect(html).to have_tag("div.level2.internacionalizacao", regexp("Internacionalização"))
  end

  it "adds id attribute to content" do
    expect(content).to have_tag("h1#item-1", regexp("Item 1"))
    expect(content).to have_tag("h2#item-1-2", regexp("Item 1.2"))
    expect(content).to have_tag("h3#item-1-1-3", regexp("Item 1.1.3"))
    expect(content).to have_tag("h4#item-1-1-1-4", regexp("Item 1.1.1.4"))
    expect(content).to have_tag("h5#item-1-1-1-1-5", regexp("Item 1.1.1.1.5"))
    expect(content).to have_tag("h6#item-1-1-1-1-1-6", regexp("Item 1.1.1.1.1.6"))

    expect(content).to have_tag("h2#item-2-1", regexp("Item 2.1"))
    expect(content).to have_tag("h2#item-2-1-again", regexp("Item 2.1 again"))

    expect(content).to have_tag("h2#internacionalizacao", regexp("Internacionalização"))
  end
end
