require "spec_helper"

describe Kitabu::Cli do
  context "while running export" do
    it "exits with status 1 when an invalid --only option is provided" do
      expect {
        capture(:stderr){ Kitabu::Cli.start(["export", "--only=invalid"]) }
      }.to exit_with_code(1)
    end

    it "exits with status 1 when no config file is found" do
      expect {
        capture(:stderr){ Kitabu::Cli.start(["export"]) }
      }.to exit_with_code(1)
    end
  end
end
