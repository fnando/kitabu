# encoding: utf-8
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

  describe "#unindent" do
    it "should unindent tabs" do
      actual = "\tdef some_method\n\t  puts 'yay'\n\tend".unindent
      expected = "def some_method\n  puts 'yay'\nend"

      actual.should == expected
    end

    it "should unindent spaces" do
      actual = "  def some_method\n    puts 'yay'\n  end".unindent
      expected = "def some_method\n  puts 'yay'\nend"

      actual.should == expected
    end

    it "should unindent both tabs and spaces" do
      actual = "\t  def some_method\n\t    puts 'yay'\n\t  end".unindent
      expected = "def some_method\n  puts 'yay'\nend"

      actual.should == expected
    end

    it "should keep string intact" do
      expected = "def some_method\n  puts 'yay'\nend"
      actual = expected.unindent

      actual.should == expected
    end
  end
end
