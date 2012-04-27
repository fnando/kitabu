require "spec_helper"

describe Kitabu::Cli do
  context "while running permalinks" do
    it "recognizes command" do
      Dir.chdir SPECDIR.join("support/mybook")
      expect {
        capture(:stdout) { Kitabu::Cli.start(["permalinks"]) }
      }.to_not raise_error
    end
  end
end
