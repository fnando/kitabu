# frozen_string_literal: true

require "spec_helper"

describe Kitabu::Markdown do
  it "enables fenced code blocks" do
    html = Kitabu::Markdown.render <<~TEXT
      ```ruby
      class User
      end
      ```
    TEXT

    expect(html).to include('<pre class="highlight ruby">')
  end

  it "enables options" do
    html = Kitabu::Markdown.render <<~TEXT
      ```php?start_inline=true
      echo 'Hello';
      ```
    TEXT

    expect(html).to include('<span class="k">echo</span>')
  end

  it "enables line numbers" do
    html = Kitabu::Markdown.render <<~TEXT
      ```ruby?line_numbers=true
      class User
      end
      ```
    TEXT

    expect(html).to include(%[<table class="rouge-table">])
  end

  it "does not raise with unknown lexers" do
    expect do
      Kitabu::Markdown.render <<~TEXT
        ```terminal
        Text plain.
        ```
      TEXT
    end.not_to raise_error
  end

  it "renders alert message using block quotes" do
    html = Kitabu::Markdown.render <<~TEXT
      > [!NOTE]
      >
      > This is just a note
    TEXT

    html = Nokogiri::HTML.fragment(html)
    selector = "div.alert-message.note > .alert-message--title"

    expect(html.css(selector).text).to eql("Just so you know…")
    expect(html.css("#{selector} + p").text).to eql("This is just a note")
  end

  it "renders alert message using custom title" do
    html = Kitabu::Markdown.render <<~TEXT
      > [!NOTE] And remember…
      >
      > This is just a note
    TEXT

    html = Nokogiri::HTML.fragment(html)
    selector = "div.alert-message.note > .alert-message--title"

    expect(html.css(selector).text).to eql("And remember…")
    expect(html.css("#{selector} + p").text).to eql("This is just a note")
  end

  it "renders arbitrary alert message using block quotes" do
    html = Kitabu::Markdown.render <<~TEXT
      > [!ALERT]
      >
      > This is just an alert
    TEXT

    html = Nokogiri::HTML.fragment(html)
    selector = "div.alert-message.alert > .alert-message--title"

    expect(html.css(selector).text).to eql("Alert")
    expect(html.css("#{selector} + p").text).to eql("This is just an alert")
  end

  it "renders regular block quotes" do
    html = Kitabu::Markdown.render <<~TEXT
      > This is just a quote
    TEXT

    html = Nokogiri::HTML.fragment(html)

    expect(html.css(".note").count).to eql(0)
    expect(html.css("blockquote").text.chomp).to eql("This is just a quote")
  end

  it "handles empty blockquote" do
    html = Kitabu::Markdown.render(">")

    expect(html).to eq("<blockquote></blockquote>")
  end

  it "calls before render hook" do
    Kitabu::Markdown.add_hook(:before_render, &:upcase)

    expect(Kitabu::Markdown.render("Hello")).to eql("<p>HELLO</p>\n")
  end

  it "calls after render hook" do
    Kitabu::Markdown.add_hook(:after_render) do |content|
      content.gsub("<p>Hello</p>", "<em>BYE</em>")
    end

    expect(Kitabu::Markdown.render("Hello")).to eql("<em>BYE</em>\n")
  end

  it "replaces inline style of table alignment" do
    html = Kitabu::Markdown.render <<~TEXT
      | Month     | Savings  | Type     | Note |
      | :-------- | -------: | :-------:| -----|
      | January   | $250     | Positive | N/A  |
    TEXT

    html = Nokogiri::HTML.fragment(html)

    expect(html).to have_tag("table.table")
    expect(html).to have_tag("table>thead>tr>th.align-left", "Month")
    expect(html).to have_tag("table>thead>tr>th.align-right", "Savings")
    expect(html).to have_tag("table>thead>tr>th.align-center", "Type")
    expect(html).to have_tag("table>thead>tr>th:not([class*='align'])", "Note")

    expect(html).to have_tag("table>tbody>tr>td.align-left", "January")
    expect(html).to have_tag("table>tbody>tr>td.align-right", "$250")
    expect(html).to have_tag("table>tbody>tr>td.align-center", "Positive")
    expect(html).to have_tag("table>tbody>tr>td:not([class*='align'])", "N/A")
  end

  it "replaces images with titles with figure" do
    html = Kitabu::Markdown.render <<~TEXT
      ![ALT](image.png "TITLE")
    TEXT

    html = Nokogiri::HTML.fragment(html)

    selector = "figure>img[src='image.png'][srcset='image.png 2x']" \
               "[alt='ALT'][title='TITLE']+figcaption"

    expect(html).to have_tag(selector, "TITLE")
  end

  it "keeps images without titles as it is" do
    html = Kitabu::Markdown.render <<~TEXT
      ![This is the alt](image.png)
    TEXT

    html = Nokogiri::HTML.fragment(html)

    expect(html).to have_tag("img[alt='This is the alt']")
    expect(html).not_to have_tag("figure")
    expect(html).not_to have_tag("figcaption")
  end

  it "sets automatic ids when defining headers" do
    html = Kitabu::Markdown.render <<~TEXT
      # My header

      ## My header

      ### My header {#my-custom-id}
    TEXT

    html = Nokogiri::HTML.fragment(html)

    expect(html).to have_tag("h1#my-header", "My header")
    expect(html).to have_tag("h2#my-header-2", "My header")
    expect(html).to have_tag("h3#my-custom-id", "My header")
  end

  it "sets custom ids when defining headers" do
    html = Kitabu::Markdown.render <<~TEXT
      # My header {#header}
    TEXT

    html = Nokogiri::HTML.fragment(html)

    expect(html).to have_tag("h1#header", "My header")
  end

  it "uses abbreviations" do
    html = Kitabu::Markdown.render <<~TEXT
      # The simplicity of HTML

      ## Styling with CSS

      Let's talk about *CSS*.

      ```ruby
      class CSS
      end
      ```

      Take a look at the `CSS` class.

      *[CSS]: Cascading Style Sheets
      *[HTML]: Hyper Text Markup Language
    TEXT

    expect(html).not_to include("*[CSS]: Cascading Style Sheets")
    expect(html).not_to include("*[HTML]: Hyper Text Markup Language")
    expect(Nokogiri::HTML.fragment(html).css("abbr").size).to equal(3)
    expect(html).to have_tag("h1 > abbr[title='Hyper Text Markup Language']",
                             "HTML")
    expect(html).to have_tag("h2 > abbr[title='Cascading Style Sheets']", "CSS")
    expect(html).to have_tag("em > abbr[title='Cascading Style Sheets']", "CSS")
    expect(html).not_to have_tag("pre abbr")
    expect(html).not_to have_tag("code abbr")
  end

  it "uses cached abbreviations" do
    abbreviations = {
      "CSS" => "Cascading Style Sheets",
      "HTML" => "Hyper Text Markup Language"
    }

    input = <<~TEXT
      # The simplicity of HTML

      ## Styling with CSS

      Let's talk about *CSS*.

      ```ruby
      class CSS
      end
      ```

      Take a look at the `CSS` class.
    TEXT

    html = Kitabu::Markdown.render(input, abbreviations:)

    expect(html).not_to include("*[CSS]: Cascading Style Sheets")
    expect(html).not_to include("*[HTML]: Hyper Text Markup Language")
    expect(Nokogiri::HTML.fragment(html).css("abbr").size).to equal(3)
    expect(html).to have_tag("h1 > abbr[title='Hyper Text Markup Language']",
                             "HTML")
    expect(html).to have_tag("h2 > abbr[title='Cascading Style Sheets']", "CSS")
    expect(html).to have_tag("em > abbr[title='Cascading Style Sheets']", "CSS")
    expect(html).not_to have_tag("pre abbr")
    expect(html).not_to have_tag("code abbr")
  end
end
