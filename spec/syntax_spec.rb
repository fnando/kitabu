require File.dirname(__FILE__) + "/spec_helper"

INLINE = '
    syntax(ruby). class Sample
      def hello(name)
        puts "hi, #{name}"
      end
    end
'

describe "Kitabu::Syntax" do
  describe "Inline" do
    it "should return code for textile" do
      markup = BlackCloth.new(INLINE)
      html = Kitabu::Syntax.process(markup.to_html, markup)

      html.should have_tag("pre.idle.ruby")
    end

    it "should return code for markdown" do
      markup = RDiscount.new(INLINE)
      html = Kitabu::Syntax.process(markup.to_html, markup)

      html.should have_tag("pre.idle.ruby")
    end
  end
  
  describe "File" do
    it "should return code for textile" do
      markup = BlackCloth.new("syntax(ruby). sample.rb")
      html = Kitabu::Syntax.process(markup.to_html, markup)

      html.should have_tag("pre.idle.ruby")
      Hpricot(html).inner_text.should match(/class Sample/)
    end

    it "should return code for markdown" do
      markup = RDiscount.new("\tsyntax(ruby). sample.rb")
      html = Kitabu::Syntax.process(markup.to_html, markup)

      html.should have_tag("pre.idle.ruby")      
      Hpricot(html).inner_text.should match(/class Sample/)
    end
  end
  
  describe "Named block" do
    it "should return code for textile" do
      markup = BlackCloth.new("syntax(ruby#method). sample.rb")
      html = Kitabu::Syntax.process(markup.to_html, markup)

      html.should have_tag("pre.idle.ruby")
      Hpricot(html).inner_text.should_not match(/class Sample/)
      Hpricot(html).inner_text.should match(/def hello/)
    end

    it "should return code for markdown" do
      markup = RDiscount.new("\tsyntax(ruby#method). sample.rb")
      html = Kitabu::Syntax.process(markup.to_html, markup)

      html.should have_tag("pre.idle.ruby")      
      Hpricot(html).inner_text.should_not match(/class Sample/)
      Hpricot(html).inner_text.should match(/def hello/)
    end
  end
  
  describe "Line range" do
    it "should return code for textile" do
      markup = BlackCloth.new("syntax(ruby 3,5). sample.rb")
      html = Kitabu::Syntax.process(markup.to_html, markup)

      html.should have_tag("pre.idle.ruby")
      Hpricot(html).inner_text.should_not match(/class Sample/)
      Hpricot(html).inner_text.should match(/def hello/)
    end

    it "should return code for markdown" do
      markup = BlackCloth.new("syntax(ruby 3,5). sample.rb")
      html = Kitabu::Syntax.process(markup.to_html, markup)

      html.should have_tag("pre.idle.ruby")      
      Hpricot(html).inner_text.should_not match(/class Sample/)
      Hpricot(html).inner_text.should match(/def hello/)
    end
  end
end
