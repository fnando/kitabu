# encoding: utf-8
require File.dirname(__FILE__) + "/spec_helper"
require "kitabu/command"

OUTPUT = []

module Kitabu
  module Command
    extend self
    
    def output(*args)
      args.each {|v| OUTPUT << v}
    end
  end
end

describe "Kitabu::Command" do
  before(:each) do
    @dir = "/tmp/kitabu-sample"
    
    OUTPUT.delete_if { true }
    ARGV.delete_if { true }
    FileUtils.rm_rf(@dir)
  end
  
  it "should copy templates" do
    run_with(@dir) do
      File.should be_file(@dir + "/Rakefile")
      File.should be_file(@dir + "/config.yml")
      File.should be_file(@dir + "/templates/layout.css")
      File.should be_file(@dir + "/templates/layout.html")
      File.should be_file(@dir + "/templates/syntax.css")
      File.should be_file(@dir + "/templates/user.css")
      
      File.should be_directory(@dir + "/text")
      File.should be_directory(@dir + "/output")
    end
  end
  
  private
    def argv!(*args)
      args.each {|v| ARGV << v }
    end
    
    def run_with(*args, &block)
      argv!(*args)
      Kitabu::Command.run!
    end
end
