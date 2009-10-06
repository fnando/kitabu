# encoding: utf-8
require File.dirname(__FILE__) + "/../spec_helper"

describe "Bug Fix" do
  describe "Issue #3" do
    before(:each) do
      ENV["KITABU_ROOT"] = File.dirname(__FILE__) + "/../fixtures/wikipedia"
      ENV["KITABU_NAME"] = "wikipedia"
    end
    
    it "should generate HTML when syntax highlight is disabled" do
      ENV["NO_SYNTAX_HIGHLIGHT"] = "1"
      Kitabu::Base.generate_html
      @html = File.read(Kitabu::Base.root_path + "/output/wikipedia.html")
      @html.should have_tag("h2", :count => 2)
    end
    
    it "should generate HTML when syntax highlight is disabled" do
      ENV.delete("NO_SYNTAX_HIGHLIGHT")
      Kitabu::Base.generate_html
      @html = File.read(Kitabu::Base.root_path + "/output/wikipedia.html")
      @html.should have_tag("h2", :count => 2)
    end
  end
end