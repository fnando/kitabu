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
    expected = <<~HTML
      <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
      <html><body><nav>
        <ol>
      <li>
      <a href="#item-1">Item 1</a><ol><li>
      <a href="#item-1-1">Item 1.1</a><ol><li>
      <a href="#item-1-1-1">Item 1.1.1</a><ol><li>
      <a href="#item-1-1-1-1">Item 1.1.1.1</a><ol><li>
      <a href="#item-1-1-1-1-1">Item 1.1.1.1.1</a>
      </li></ol>
      </li></ol>
      </li></ol>
      </li></ol>
      </li>
      <li>
      <a href="#item-2">Item 2</a><ol><li>
      <a href="#item-2-1">Item 2.1</a><ol>
      <li>
      <a href="#item-2-1-1">Item 2.1.1</a>
      </li>
      <li>
      <a href="#item-2-1-2">Item 2.1.2</a>
      </li>
      </ol>
      </li></ol>
      </li>
      <li>
      <a href="#item-3">Item 3</a>
      </li>
      <li>
      <a href="#internacionalizacao">Internacionalização</a>
      </li>
      <li>
      <a href="#title">Title</a>
      </li>
      <li>
      <a href="#title-2">Title</a>
      </li>
      </ol>
      </nav></body></html>
    HTML

    expect(expected).to eql(toc.to_s)
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
