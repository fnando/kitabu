require "spec_helper"

describe RedCloth do
  describe "#figure" do
    it "renders html" do
      html = RedCloth.convert("figure(The Rails logo). rails.png")
      expect(html).to have_tag("p.figure") do |p|
        expect(p).to have_tag("img[@src='../images/rails.png'][@alt='The Rails logo']")
        expect(p).to have_tag("span.caption", "The Rails logo")
      end
    end
  end

  describe "#note" do
    it "renders html" do
      html = RedCloth.convert("note. Some important note!")
      expect(html).to have_tag("p.note", "Some important note!")
    end
  end

  describe "#attention" do
    it "renders html" do
      html = RedCloth.convert("attention. Some warning note!")
      expect(html).to have_tag("p.attention", "Some warning note!")
    end
  end

  describe "#file" do
    it "renders html" do
      allow(Kitabu).to receive_message_chain(:config).and_return(base_url: "http://example.com")
      html = RedCloth.convert("file. app/models/users.rb")

      expect(html).to have_tag("p.file") do |p|
        expect(p).to have_tag("a[@href='http://example.com/app/models/users.rb']", "app/models/users.rb")
      end
    end
  end

  context "custom footnote helper" do
    it "renders html" do
      html = RedCloth.convert("Writing some text with a footnote %{this is a footnote}")
      expect(html).to eq(%[<p>Writing some text with a footnote<span class="footnote">this is a footnote</span></p>])
    end

    it "ignores escaped notations" do
      html = RedCloth.convert("It must skip \\%{this}")
      expect(html).to eq(%[<p>It must skip %{this}</p>])
    end
  end

  context "custom url helper" do
    it "renders html" do
      html = RedCloth.convert("<http://example.com>")
      expect(html).to eq(%[<p><a href="http://example.com">http://example.com</a></p>])
    end
  end
end
