# frozen_string_literal: true

require "spec_helper"

describe Kitabu::Cli do
  context "while running permalinks" do
    before { Dir.chdir SPECDIR.join("support/mybook") }

    it "recognizes command" do
      expect do
        capture(:stdout) { Kitabu::Cli.start(["permalinks"]) }
      end.to_not raise_error
    end

    it "outputs permalinks" do
      stdout = capture(:stdout) { Kitabu::Cli.start(["permalinks"]) }
      expected =
        "* Markdown: #markdown\n" \
        "* ERB: #erb\n" \
        "* Some Chapter: #some-chapter\n" \
        "** Simple > Complex: #simple-complex\n" \
        "* Revisions: #revisions\n" \
        "** Version 1: #version-1\n"

      expect(stdout).to eql(expected)
    end
  end
end
