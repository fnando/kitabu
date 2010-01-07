# encoding: utf-8
require File.dirname(__FILE__) + "/../spec_helper"

describe "BlackCloth" do
  it "should parse figure tag" do
    @html = BlackCloth.new("figure(The Rails logo). rails.png").to_html
    @html.should have_tag("p.figure") do |p|
      p.should have_tag("img[@src=../images/rails.png][@style='width: 87px; height: 111px'][@alt='The Rails logo']")
      p.should have_tag("span.caption", "The Rails logo")
    end
  end

  it "should parse note tag" do
    @html = BlackCloth.new("note. Some important note!").to_html
    @html.should have_tag("p.note", "Some important note!")
  end

  it "should parse attention tag" do
    @html = BlackCloth.new("attention. Some warning note!").to_html
    @html.should have_tag("p.attention", "Some warning note!")
  end

  it "should link to file" do
    Kitabu::Base.should_receive(:config).and_return("base_url" => "http://example.com")
    @html = BlackCloth.new("file. app/models/users.rb").to_html

    @html.should have_tag("p.file") do |p|
      p.should have_tag("a[@href=http://example.com/app/models/users.rb]", "app/models/users.rb")
    end
  end

  it "should create footnote" do
    @html = BlackCloth.new("Writing some text with a footnote %{this is a footnote}").to_html
    @html.should == %(<p>Writing some text with a footnote<span class="footnote">this is a footnote</span></p>)
  end

  it "should link url" do
    @html = BlackCloth.new("<http://example.com>").to_html
    @html.should == %(<a href="http://example.com">http://example.com</a>)
  end
end