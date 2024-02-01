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

  it "renders alert boxes using block quotes" do
    html = Kitabu::Markdown.render <<~TEXT
      > [!NOTE]
      >
      > This is just a note
    TEXT

    html = Nokogiri::HTML(html)
    selector = "div.note.info > .note--title"

    expect(html.css(selector).text).to eql("Info")
    expect(html.css("#{selector} + p").text).to eql("This is just a note")
  end

  it "renders arbitrary alert boxes using block quotes" do
    html = Kitabu::Markdown.render <<~TEXT
      > [!ALERT]
      >
      > This is just an alert
    TEXT

    html = Nokogiri::HTML(html)
    selector = "div.note.alert > .note--title"

    expect(html.css(selector).text).to eql("Alert")
    expect(html.css("#{selector} + p").text).to eql("This is just an alert")
  end

  it "renders regular block quotes" do
    html = Kitabu::Markdown.render <<~TEXT
      > This is just a quote
    TEXT

    html = Nokogiri::HTML(html)

    expect(html.css(".note").count).to eql(0)
    expect(html.css("blockquote").text.chomp).to eql("This is just a quote")
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

    html = Nokogiri::HTML(html)

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
end
