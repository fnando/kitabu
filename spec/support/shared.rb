# frozen_string_literal: true

shared_examples_for "e-book" do
  let(:mybook) { tmpdir.join("mybook") }

  it "generates e-book" do
    expect(mybook).to be_directory
  end

  it "creates images directory" do
    expect(mybook.join("assets/images/cover.png")).to be_file
  end

  it "creates text directory" do
    expect(mybook.join("text")).to be_directory
  end

  it "creates fonts directory" do
    expect(mybook.join("assets/fonts")).to be_directory
  end

  it "creates template directory" do
    expect(mybook.join("templates")).to be_directory
  end

  it "creates configuration file" do
    expect(mybook.join("config/kitabu.yml")).to be_file
  end

  it "creates helper file" do
    expect(mybook.join("config/helpers.rb")).to be_file
  end

  it "copies sample texts" do
    expect(mybook.join("text/01_Getting_Started.md")).to be_file
    expect(mybook.join("text/02_Creating_Chapters.md")).to be_file
    expect(mybook.join("text/03_Syntax_Highlighting.md.erb")).to be_file
    expect(mybook.join("text/04_Dynamic_Content.md.erb")).to be_file
    expect(mybook.join("text/05_Exporting_Files.md")).to be_file
  end

  it "copies Guardfile" do
    expect(mybook.join("Guardfile")).to be_file
  end

  it "copies stylesheets" do
    expect(mybook.join("assets/styles")).to be_directory
    expect(mybook.join("assets/styles/epub.css")).to be_file
    expect(mybook.join("assets/styles/print.css")).to be_file
    expect(mybook.join("assets/styles/pdf.css")).to be_file
    expect(mybook.join("assets/styles/html.css")).to be_file
  end

  it "creates kitabu.css" do
    expect(mybook.join("assets/styles/support/kitabu.css")).to be_file
  end

  it "copies Gemfile" do
    expect(mybook.join("Gemfile")).to be_file
  end

  it "copies html template files" do
    expect(mybook.join("templates/html/layout.erb")).to be_file
  end

  it "copies epub template files" do
    expect(mybook.join("templates/epub/cover.erb")).to be_file
    expect(mybook.join("templates/epub/page.erb")).to be_file
    expect(mybook.join("templates/epub/toc.erb")).to be_file
  end
end
