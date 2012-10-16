shared_examples_for "e-book" do
  let(:mybook) { tmpdir.join("mybook") }

  it "generates e-book" do
    mybook.should be_directory
  end

  it "creates images directory" do
    mybook.join("images").should be_directory
  end

  it "creates text directory" do
    mybook.join("text").should be_directory
  end

  it "creates code directory" do
    mybook.join("code").should be_directory
  end

  it "creates template directory" do
    mybook.join("templates").should be_directory
  end

  it "creates configuration file" do
    mybook.join("config/kitabu.yml").should be_file
  end

  it "creates helper file" do
    mybook.join("config/helper.rb").should be_file
  end

  it "copies sample page" do
    mybook.join("text/01_Welcome.md")
  end

  it "copies Guardfile" do
    mybook.join("Guardfile")
  end

  it "copies html template files" do
    mybook.join("templates/html/user.css").should be_file
    mybook.join("templates/html/layout.css").should be_file
    mybook.join("templates/html/layout.erb").should be_file
    mybook.join("templates/html/syntax.css").should be_file
  end

  it "copies epub template files" do
    mybook.join("templates/epub/user.css").should be_file
    mybook.join("templates/epub/cover.erb").should be_file
    mybook.join("templates/epub/cover.png").should be_file
    mybook.join("templates/epub/page.erb").should be_file
  end
end