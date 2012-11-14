# -*- encoding: utf-8 -*-
require "spec_helper"

describe Kitabu::TOC::HTML do
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
    content.should_not match(/<body>/)
  end

  it "generates toc" do
    html.should have_tag("div.level1.item-1", "Item 1")
    html.should have_tag("div.level2.item-1-2", "Item 1.2")
    html.should have_tag("div.level3.item-1-1-3", "Item 1.1.3")
    html.should have_tag("div.level4.item-1-1-1-4", "Item 1.1.1.4")
    html.should have_tag("div.level5.item-1-1-1-1-5", "Item 1.1.1.1.5")
    html.should have_tag("div.level6.item-1-1-1-1-1-6", "Item 1.1.1.1.1.6")

    html.should have_tag("div.level2.item-2-1", "Item 2.1")
    html.should have_tag("div.level2.item-2-1-again", "Item 2.1 again")

    html.should have_tag("div.level2.internacionalizacao", "Internacionalização")
  end

  it "adds id attribute to content" do
    content.should have_tag("h1#item-1", "Item 1")
    content.should have_tag("h2#item-1-2", "Item 1.2")
    content.should have_tag("h3#item-1-1-3", "Item 1.1.3")
    content.should have_tag("h4#item-1-1-1-4", "Item 1.1.1.4")
    content.should have_tag("h5#item-1-1-1-1-5", "Item 1.1.1.1.5")
    content.should have_tag("h6#item-1-1-1-1-1-6", "Item 1.1.1.1.1.6")

    content.should have_tag("h2#item-2-1", "Item 2.1")
    content.should have_tag("h2#item-2-1-again", "Item 2.1 again")

    content.should have_tag("h2#internacionalizacao", "Internacionalização")
  end
end
