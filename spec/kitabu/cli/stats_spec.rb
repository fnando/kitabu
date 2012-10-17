require "spec_helper"

describe Kitabu::Cli, "while running stats" do
  let(:root_dir) { SPECDIR.join("support/mybook") }
  before { Dir.chdir(root_dir) }

  it "recognizes command" do
    expect {
      capture(:stdout) { Kitabu::Cli.start(["stats"]) }
    }.to_not raise_error
  end

  it "initializes stats with root dir" do
    Kitabu::Stats
      .should_receive(:new)
      .with(root_dir)
      .and_return(mock.as_null_object)

    capture(:stdout) { Kitabu::Cli.start(["stats"]) }
  end

  context "outputting stats" do
    let(:stats) { mock("stats", {
      :chapters => 4,
      :words => 50,
      :images => 10,
      :footnotes => 15,
      :links => 20,
      :code_blocks => 25
    })}

    before { Kitabu::Stats.stub :new => stats }
    subject(:output) {
      capture(:stdout) { Kitabu::Cli.start(["stats"]) }
    }

    it { expect(output).to include("Chapters: 4") }
    it { expect(output).to include("Words: 50") }
    it { expect(output).to include("Images: 10") }
    it { expect(output).to include("Footnotes: 15") }
    it { expect(output).to include("Links: 20") }
    it { expect(output).to include("Code blocks: 25") }
  end
end
