# -*- encoding: utf-8 -*-
require "spec_helper"

describe String do
  describe "#to_permalink" do
    it "should normalize strings" do
      {
        'This IS a Tripped out title!!.!1  (well/ not really)' => 'this-is-a-tripped-out-title-1-well-not-really',
        '////// meph1sto r0x ! \\\\\\' => 'meph1sto-r0x',
        'āčēģīķļņū' => 'acegiklnu',
        '中文測試 chinese text' => 'chinese-text',
        'some-)()()-ExtRa!/// .data==?>    to \/\/test' => 'some-extra-data-to-test',
        'http://simplesideias.com.br/tags/' => 'http-simplesideias-com-br-tags',
        "Don't Repeat Yourself (DRY)" => 'don-t-repeat-yourself-dry',
        "Text\nwith\nline\n\n\tbreaks" => 'text-with-line-breaks'
      }.each do |dirty, normalized|
        dirty.to_permalink.should == normalized
      end
    end
  end
end
