# frozen_string_literal: true

require "spec_helper"

describe Kitabu::Cli do
  context "while running permalinks" do
    it "recognizes command" do
      Dir.chdir SPECDIR.join("support/mybook")

      expect do
        capture(:stdout) { Kitabu::Cli.start(["permalinks"]) }
      end.to_not raise_error
    end
  end
end
