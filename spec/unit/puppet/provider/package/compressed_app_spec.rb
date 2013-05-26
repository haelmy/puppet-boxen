#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:package).provider(:compressed_app) do
  name = 'somepackage'
  
  let(:resource) { Puppet::Type.type(:package).new(:name => name, :provider => :compressed_app) }
  let(:provider) { described_class.new(resource) }

  describe "when checking if the compressed app is installed" do
    
    it "should check for the existance of the db-file" do
      File.expects(:exists?).with("/var/db/.puppet_compressed_app_installed_#{name}")
      
      provider.query
    end
    
    it "should return nil if the db-file does not exist" do
      File.stubs(:exists?).returns(false)
      
      provider.query.should == nil
    end
    
    it "should return the packages name and ensure its installed if the db-file is present" do
      File.stubs(:exists?).returns(true)
      
      provider.query.should == {:name => name, :ensure => :installed}
    end
  end

end