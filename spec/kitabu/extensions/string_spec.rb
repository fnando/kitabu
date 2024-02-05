# frozen_string_literal: true

# rubocop:disable Layout/LineLength

require "spec_helper"

describe String do
  using Kitabu::Extensions

  describe "#to_permalink" do
    it "normalizes strings" do
      {
        "Simple > Complex" => "simple-complex",
        "This IS a Tripped out title!!.!1  (well/ not really)" => "this-is-a-tripped-out-title-1-well-not-really",
        "////// meph1sto r0x ! \\\\\\" => "meph1sto-r0x",
        "āčēģīķļņū" => "acegiklnu",
        "中文測試 chinese text" => "chinese-text",
        'some-)()()-ExtRa!/// .data==?>    to \/\/test' => "some-extra-data-to-test",
        "http://simplesideias.com.br/tags/" => "http-simplesideias-com-br-tags",
        "Don't Repeat Yourself (DRY)" => "don-t-repeat-yourself-dry",
        "Text\nwith\nline\n\n\tbreaks" => "text-with-line-breaks"
      }.each do |dirty, normalized|
        expect(dirty.to_permalink).to eq(normalized)
      end
    end
  end
end

# rubocop:enable Layout/LineLength
