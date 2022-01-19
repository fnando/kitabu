# frozen_string_literal: true

require "spec_helper"

describe Kitabu::Footnotes::HTML do
  let(:footnotes) do
    Kitabu::Markdown.render <<-MARKDOWN.strip_heredoc
      ohai[^1] and kthxbai[^2]

      ohai[^1] again.

      [^1]: Hello
      [^2]: OK, thanks. Bye!
    MARKDOWN
  end

  let(:content) do
    <<-HTML.strip_heredoc
      <div class="chapter">
        #{footnotes}
      </div>

      <div class="chapter">
        #{footnotes}
      </div>
    HTML
  end

  let(:html) do
    Kitabu::Footnotes::HTML.process(content).html
  end

  let(:chapter1) { html.css(".chapter:first-of-type").first }
  let(:chapter2) { html.css(".chapter:last-of-type").first }

  it "sets starting index" do
    expect(chapter1).to have_tag('.footnotes ol[start="1"]')
    expect(chapter2).to have_tag('.footnotes ol[start="3"]')
  end

  it "sets footnotes id" do
    html.css(".footnotes li").to_enum(:each).with_index(1) do |footnote, index|
      expect(footnote.get_attribute("id")).to eq("fn#{index}")
    end
  end

  it "removes id from existing <sup>" do
    expect(chapter1).to have_tag("sup:not([id])", count: 1)
    expect(chapter2).to have_tag("sup:not([id])", count: 1)
  end

  it "sets <sup> id" do
    expect(chapter1).to have_tag("sup", count: 3)
    expect(chapter1).to have_tag("sup[id=fnref1]", count: 1)
    expect(chapter1).to have_tag("sup[id=fnref2]", count: 1)

    expect(chapter2).to have_tag("sup", count: 3)
    expect(chapter2).to have_tag("sup[id=fnref3]", count: 1)
    expect(chapter2).to have_tag("sup[id=fnref4]", count: 1)
  end

  it "updates link to footnote" do
    expect(chapter1).to have_tag("sup:nth-child(1) > a", text: "1", count: 2)
    expect(chapter1).to have_tag("sup:nth-child(2) > a", text: "2", count: 1)

    expect(chapter2).to have_tag("sup:nth-child(1) > a", text: "3", count: 2)
    expect(chapter2).to have_tag("sup:nth-child(2) > a", text: "4", count: 1)
  end

  it "sets footnote link-back" do
    expect(chapter1).to have_tag('.footnotes li:nth-child(1) a[href="#fnref1"]')
    expect(chapter1).to have_tag('.footnotes li:nth-child(2) a[href="#fnref2"]')

    expect(chapter2).to have_tag('.footnotes li:nth-child(1) a[href="#fnref3"]')
    expect(chapter2).to have_tag('.footnotes li:nth-child(2) a[href="#fnref4"]')
  end
end
