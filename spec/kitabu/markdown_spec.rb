# frozen_string_literal: true

require "spec_helper"

describe Kitabu::Markdown do
  it "enables fenced code blocks" do
    html = Kitabu::Markdown.render <<-TEXT.strip_heredoc
      ```ruby
      class User
      end
      ```
    TEXT

    expect(html).to include('<pre class="highlight ruby">')
  end

  it "enables options" do
    html = Kitabu::Markdown.render <<-TEXT.strip_heredoc
    ```php?start_inline=true
    echo 'Hello';
    ```
    TEXT

    expect(html).to include('<span class="k">echo</span>')
  end

  it "enables line numbers" do
    html = Kitabu::Markdown.render <<-TEXT.strip_heredoc
    ```ruby?line_numbers=true
    class User
    end
    ```
    TEXT

    expect(html).to include(%[<table class="rouge-table">])
  end

  it "does not raise with unknown lexers" do
    expect do
      Kitabu::Markdown.render <<-TEXT.strip_heredoc
      ```terminal
      Text plain.
      ```
      TEXT
    end.not_to raise_error
  end

  it "renders alert boxes using block quotes" do
    html = Kitabu::Markdown.render <<-TEXT.strip_heredoc
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
    html = Kitabu::Markdown.render <<-TEXT.strip_heredoc
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
    html = Kitabu::Markdown.render <<-TEXT.strip_heredoc
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
end
