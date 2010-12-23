require "spec_helper"

describe RedCloth do
  describe "#figure" do
    it "should render html" do
      html = RedCloth.new("figure(The Rails logo). rails.png").to_html
      html.should have_tag("p.figure") do |p|
        p.should have_tag("img[@src='../images/rails.png'][@alt='The Rails logo']")
        p.should have_tag("span.caption", "The Rails logo")
      end
    end
  end

  describe "#note" do
    it "should render html" do
      html = RedCloth.new("note. Some important note!").to_html
      html.should have_tag("p.note", "Some important note!")
    end
  end

  describe "#attention" do
    it "should render html" do
      html = RedCloth.new("attention. Some warning note!").to_html
      html.should have_tag("p.attention", "Some warning note!")
    end
  end

  describe "#file" do
    it "should render html" do
      Kitabu.stub :config => { "base_url" => "http://example.com" }
      html = RedCloth.new("file. app/models/users.rb").to_html

      html.should have_tag("p.file") do |p|
        p.should have_tag("a[@href='http://example.com/app/models/users.rb']", "app/models/users.rb")
      end
    end
  end

  context "custom footnote helper" do
    it "should render html" do
      html = RedCloth.new("Writing some text with a footnote %{this is a footnote}").to_html(:textile, :footnote)
      html.should == %[<p>Writing some text with a footnote<span class="footnote">this is a footnote</span></p>]
    end
  end

  context "custom url helper" do
    it "should render html" do
      html = RedCloth.new("<http://example.com>").to_html(:textile, :link)
      html.should == %[<p><a href="http://example.com">http://example.com</a></p>]
    end
  end

  describe ".convert" do
    it "should render html" do
      textile = "figure. some_image.png\n\n<http://example.com>"
      html = RedCloth.convert(textile)

      html.should have_tag("p.figure", 1)
      html.should have_tag("a[@href='http://example.com']", "http://example.com")
    end
  end
end
