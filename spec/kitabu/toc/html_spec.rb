# frozen_string_literal: true

require "spec_helper"

describe Kitabu::TOC::HTML do
  def regexp(text)
    /#{Regexp.escape(text)}/
  end

  def input
    (+<<-HTML).force_encoding("utf-8")
      <h2>Item 1</h2>
      <h3>Item 1.1</h3>
      <h4>Item 1.1.1</h4>
      <h5>Item 1.1.1.1</h5>
      <h6>Item 1.1.1.1.1</h6>

      <h2>Item 2</h2>
      <h3>Item 2.1</h3>
      <h4>Item 2.1.1</h4>
      <h4>Item 2.1.2</h4>

      <h2>Item 3</h2>
      <h2>Internacionalização</h2>

      <!-- Duplicated titles -->
      <h2>Title</h2>
      <h2>Title</h2>
    HTML
  end

  let(:result) { described_class.generate(Nokogiri::HTML(input)) }
  let(:toc) { Nokogiri::HTML(result.toc) }
  let(:html) { result.html }

  it "generates toc" do
    paths = {
      "ol.level1>li:nth-child(1)>a" => "Item 1",
      "ol.level1>li:nth-child(1) ol.level2 > li:nth-child(1)>a" => "Item 1.1",
      "ol.level1>li:nth-child(1) ol.level2 ol.level3 > li:nth-child(1)>a" => "Item 1.1.1",
      "ol.level1>li:nth-child(1) ol.level2 ol.level3 ol.level4 > li:nth-child(1)>a" => "Item 1.1.1.1",
      "ol.level1>li:nth-child(1) ol.level2 ol.level3 ol.level4 ol.level5 > li:nth-child(1)>a" => "Item 1.1.1.1.1",

      "ol.level1>li:nth-child(2)>a" => "Item 2",
      "ol.level1>li:nth-child(2) ol.level2 > li:nth-child(1)>a" => "Item 2.1",
      "ol.level1>li:nth-child(2) ol.level2 ol.level3 > li:nth-child(1)>a" => "Item 2.1.1",

      "ol.level1>li:nth-child(3)>a" => "Item 3",
      "ol.level1>li:nth-child(4)>a[href='#internacionalizacao']" => "Internacionalização",
      "ol.level1>li:nth-child(5)>a[href='#title']" => "Title",
      "ol.level1>li:nth-child(6)>a[href='#title-2']" => "Title"

    }

    paths.each do |path, text|
      expect(toc).to have_tag(path, text)
    end
  end

  it "adds ids to original titles" do
    paths = {
      "h2#item-1" => "Item 1",
      "h3#item-1-1" => "Item 1.1",
      "h4#item-1-1-1" => "Item 1.1.1",
      "h5#item-1-1-1-1" => "Item 1.1.1.1",
      "h6#item-1-1-1-1-1" => "Item 1.1.1.1.1",

      "h2#item-2" => "Item 2",
      "h3#item-2-1" => "Item 2.1",
      "h4#item-2-1-1" => "Item 2.1.1",
      "h4#item-2-1-2" => "Item 2.1.2",

      "h2#item-3" => "Item 3",
      "h2#internacionalizacao" => "Internacionalização",
      "h2#title" => "Title",
      "h2#title-2" => "Title"

    }

    paths.each do |path, text|
      expect(html).to have_tag(path, text)
    end
  end

  it "adds content link" do
    expect(html).to have_tag("h2#item-1 > a[href='#item-1'][tabindex='-1']")
  end
end
