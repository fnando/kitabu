shared_examples_for "e-book" do
  it "generate new directory structure" do
    File.should be_directory(tmpdir.join("mybook"))
    File.should be_directory(tmpdir.join("mybook/images"))
    File.should be_directory(tmpdir.join("mybook/text"))
    File.should be_directory(tmpdir.join("mybook/code"))
    File.should be_directory(tmpdir.join("mybook/templates"))

    File.should be_file(tmpdir.join("mybook/config/kitabu.yml"))
    File.should be_file(tmpdir.join("mybook/config/helper.rb"))
    File.should be_file(tmpdir.join("mybook/templates/user.css"))
    File.should be_file(tmpdir.join("mybook/templates/layout.css"))
    File.should be_file(tmpdir.join("mybook/templates/layout.erb"))
    File.should be_file(tmpdir.join("mybook/templates/syntax.css"))
  end
end
