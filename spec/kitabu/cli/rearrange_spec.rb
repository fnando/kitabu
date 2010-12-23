require "spec_helper"

describe Kitabu::Cli do
  context "while running rearrange" do
    it "does something" do
      Dir.chdir SPECDIR.join("support/mybook")
      Kitabu::Cli.start(["rearrange"])
    end
  end
end
