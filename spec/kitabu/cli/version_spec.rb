# frozen_string_literal: false

require "spec_helper"

describe Kitabu::Cli do
  context "while running version" do
    it "outputs version" do
      %w[version -v --version].each do |arg|
        output = capture(:stdout) { Kitabu::Cli.start([arg]) }.chomp
        expect(output).to eq("Kitabu version #{Kitabu::Version::STRING}")
      end
    end
  end
end
