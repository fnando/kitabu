require File.dirname(__FILE__) + "/spec_helper"

describe "Kitabu::Base" do
  describe "Defaults" do
    it "should be a valid theme" do
      Kitabu::Base.should be_theme(Kitabu::Base::DEFAULT_THEME)
    end
    
    it "should be a valid layout" do
      Kitabu::Base.should be_layout(Kitabu::Base::DEFAULT_LAYOUT)
    end
  end
  
  describe "Paths" do
    it "should return PDF path" do
      Kitabu::Base.pdf_path.should == File.join(KITABU_ROOT, "output", "rails-guides.pdf")
    end
    
    it "should return HTML path" do
      Kitabu::Base.html_path.should == File.join(KITABU_ROOT, "output", "rails-guides.html")
    end
    
    it "should return layout template path" do
      Kitabu::Base.template_path.should == File.join(KITABU_ROOT, "templates", "layout.html")
    end
    
    it "should return config path" do
      Kitabu::Base.config_path.should == File.join(KITABU_ROOT, "config.yml")
    end
    
    it "should return text directory" do
      Kitabu::Base.text_dir.should == File.join(KITABU_ROOT, "text")
    end
  end
  
  describe "Configuration" do
    it "should load configuration file" do
      YAML.should_receive(:load_file).with(Kitabu::Base.config_path)
      Kitabu::Base.config
    end
  end
  
  describe "Helpers" do
    it "should return app name" do
      Kitabu::Base.app_name.should == "rails-guides"
    end
    
    it "should return default app name" do
      ENV["KITABU_NAME"] = nil
      Kitabu::Base.app_name.should == "kitabu"
    end
    
    it "should return permalink" do
      Kitabu::Base.to_permalink("Internacionalização no Ruby on Rails").should == "internacionalizacao-no-ruby-on-rails"
    end
    
    it "should return layout list" do
      Kitabu::Base.layouts.should == %w(boom)
    end
    
    it "should return theme list" do
      Kitabu::Base.themes.should == %w(active4d blackboard dawn eiffel idle iplastic lazy mac_classic slush_poppies sunburst)
    end
    
    it "should return syntax list" do
      Kitabu::Base.syntaxes.should == Uv.syntaxes
    end
  end
  
  describe "Markdown processors" do
    it "should return default processor" do
      Kitabu::Base.stub!(:config).and_return({})
      Kitabu::Base.markdown_processor_class.should == ::RDiscount
    end
    
    it "should return maruku processor" do
      ::Maruku = mock("Maruku")
      Kitabu::Base.stub!(:config).and_return("markdown" => "maruku")
      Kitabu::Base.markdown_processor_class.should == ::Maruku
    end
    
    it "should return bluecloth processor" do
      ::BlueCloth = mock("BlueCloth")
      Kitabu::Base.stub!(:config).and_return("markdown" => "bluecloth")
      Kitabu::Base.markdown_processor_class.should == ::BlueCloth
    end
    
    it "should return bluecloth processor" do
      ::PEGMarkdown = mock("PEGMarkdown")
      Kitabu::Base.stub!(:config).and_return("markdown" => "peg_markdown")
      Kitabu::Base.markdown_processor_class.should == ::PEGMarkdown
    end
  end
  
  describe "PDF generation" do
    it "should execute command and close connection" do
      cmd = "prince %s -o %s" % [Kitabu::Base.html_path, Kitabu::Base.pdf_path]
      io = mock("IO")
      
      io.should_receive(:close)
      IO.should_receive(:popen).with(cmd).and_return(io)
      
      Kitabu::Base.generate_pdf
    end
  end
  
  describe "HTML generation" do
    before(:each) do
      FileUtils.rm_rf(KITABU_ROOT + "/output")
      ENV["KITABU_NAME"] = File.basename(KITABU_ROOT)
      
      Kitabu::Base.generate_html
      @html = File.read(Kitabu::Base.html_path)
    end
    
    it "should generate file" do
      File.should be_file(Kitabu::Base.html_path)
    end
    
    it "should set TOC" do
      @html.should have_tag("#table-of-contents div.level2")
    end
    
    it "should set meta tags" do
      @html.should have_tag(%(meta[@name=author])) do |tag|
        tag["content"].should == "The Ruby on Rails community"
      end
      
      @html.should have_tag(%(meta[@name=subject])) do |tag|
        tag["content"].should == "These guides are designed to make you immediately productive with Rails, and to help you understand how all of the pieces fit together."
      end
      
      @html.should have_tag(%(meta[@name=keywords])) do |tag|
        tag["content"].should == "ruby, ruby on rails, documentation"
      end
    end
    
    it "should set title" do
      @html.should have_tag("#cover h1", "Rails Guides")
    end
    
    it "should separate text into chapters" do
      @html.should have_tag("div.chapter", :count => 3)
    end
    
    it "should parse textile files" do
      @html.should have_tag("div.chapter h2#introduction", "Introduction")
    end
    
    it "should parse markdown files" do
      @html.should have_tag("div.chapter h2#rails-internationalization-i18n-api", "Rails Internationalization (I18n) API")
    end
  end
  
  describe "Table of contents" do
    before(:each) do
      @html = <<-HTML
        <h1>Item 1</h1>
        <h2>Item 1.2</h2>
        <h3>Item 1.1.3</h3>
        <h4>Item 1.1.1.4</h4>
        <h5>Item 1.1.1.1.5</h5>
        <h6>Item 1.1.1.1.1.6</h6>
        
        <h2>Item 2.1</h2>
        <h2>Item 2.1 again</h2>
        <h2>Internacionalização</h2>
      HTML
      
      @contents, @toc = Kitabu::Base.table_of_contents(@html)
    end
    
    it "should generate toc" do
      @toc.should have_tag("div.level2.item-1-2", "Item 1.2")
      @toc.should have_tag("div.level3.item-1-1-3", "Item 1.1.3")
      @toc.should have_tag("div.level4.item-1-1-1-4", "Item 1.1.1.4")
      @toc.should have_tag("div.level5.item-1-1-1-1-5", "Item 1.1.1.1.5")
      @toc.should have_tag("div.level6.item-1-1-1-1-1-6", "Item 1.1.1.1.1.6")
      
      @toc.should have_tag("div.level2.item-2-1", "Item 2.1")
      @toc.should have_tag("div.level2.item-2-1-again", "Item 2.1 again")
      
      @toc.should have_tag("div.level2.internacionalizacao", "Internacionalização")
    end
    
    it "should add ID attribute to content" do
      @contents.should have_tag("h2#item-1-2", "Item 1.2")
      @contents.should have_tag("h3#item-1-1-3", "Item 1.1.3")
      @contents.should have_tag("h4#item-1-1-1-4", "Item 1.1.1.4")
      @contents.should have_tag("h5#item-1-1-1-1-5", "Item 1.1.1.1.5")
      @contents.should have_tag("h6#item-1-1-1-1-1-6", "Item 1.1.1.1.1.6")
      
      @contents.should have_tag("h2#item-2-1", "Item 2.1")
      @contents.should have_tag("h2#item-2-1-again", "Item 2.1 again")
      
      @contents.should have_tag("h2#internacionalizacao", "Internacionalização")
    end
  end
end
