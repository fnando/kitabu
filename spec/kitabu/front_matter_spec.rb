# frozen_string_literal: true

require "spec_helper"

describe Kitabu::FrontMatter do
  it "works when content doesn't have front matter" do
    matter = Kitabu::FrontMatter.parse("Hello")

    expect(matter.content).to eql("Hello")
    expect(matter.meta).to eql({})
  end

  it "parses front matter" do
    content = <<~MD
      # This is my text

      And this is some content
    MD

    original = <<~MD
      ---
      a: 1
      ---

      #{content}
    MD

    matter = Kitabu::FrontMatter.parse(original)

    expect(matter.content).to eql(content)
    expect(matter.meta["a"]).to eql(1)
  end

  it "ignores front matter that's preceeded by content" do
    content = <<~MD
      # This is my text

      And this is some content

      ---
      b: 2
      ---
    MD

    original = <<~MD
      ---
      a: 1
      ---

      #{content}
    MD

    matter = Kitabu::FrontMatter.parse(original)

    expect(matter.content).to eql(content)
    expect(matter.meta["a"]).to eql(1)
    expect(matter.meta["b"]).to be_nil
  end

  it "ignores blank lines preceeding front matter" do
    content = <<~MD
      # This is my text

      And this is some content
    MD

    original = <<~MD



      ---
      a: 1
      ---

      #{content}
    MD

    matter = Kitabu::FrontMatter.parse(original)

    expect(matter.content).to eql(content)
    expect(matter.meta["a"]).to eql(1)
  end
end
