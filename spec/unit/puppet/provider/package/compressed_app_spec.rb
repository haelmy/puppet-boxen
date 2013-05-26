#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:package).provider(:compressed_app) do
  name = 'somepackage'
  source = 'http://example.com/source_file_1.0.0.zip'

  let(:resource) {
    Puppet::Type.type(:package).new(
      :name => name,
      :source => source,
      :provider => :compressed_app
    )
  }
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

    describe "check if the db-files content matches the parameters" do
      file_handle = nil

      before do
        File.stubs(:exists?).returns(true)
        file_handle = mock 'filehandle'
        file_handle.stubs(:close)
      end

      it "should return nil if the db-file does not have the correct content" do
        file_handle.stubs(:read).returns(
          "name: '#{name}'\n" \
          "source: http://example.com/new-version-1.0.1.zip"
        )
        File.stubs(:open).returns(file_handle)

        provider.query.should == nil
      end

      it "should return the packages name and ensure it is installed if the db-file has the correct content" do
        file_handle.stubs(:read).returns(
          "name: '#{name}'\n" \
          "source: '#{source}'\n"
        )
        File.stubs(:open).returns(file_handle)

        provider.query.should == {:name => name, :ensure => :installed}
      end
    end
  end

end