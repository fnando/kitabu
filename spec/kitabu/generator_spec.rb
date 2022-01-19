# frozen_string_literal: true

require "spec_helper"

describe Kitabu::Generator do
  before do
    subject.destination_root = tmpdir.join("mybook")
    capture(:stdout) { subject.invoke_all }
  end

  it_behaves_like "e-book"
end
