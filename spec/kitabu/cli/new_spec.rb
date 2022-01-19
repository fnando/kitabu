# frozen_string_literal: true

require "spec_helper"

describe Kitabu::Cli do
  context "while running new" do
    context "when all params are valid" do
      before do
        capture(:stdout) do
          Kitabu::Cli.start(["new", tmpdir.join("mybook").to_s])
        end
      end

      it_behaves_like "e-book"
    end

    it "exits with status 1 when no path is provided" do
      expect(lambda {
        capture(:stderr) { Kitabu::Cli.start(["new"]) }
      }).to exit_with_code(1)

      expect(File).not_to be_directory(tmpdir.join("mybook"))
    end
  end
end
