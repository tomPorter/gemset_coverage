require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
module GemCov
  describe "Gem Listing" do
    it "should add gem versions" do
      gemlisting = GemListing.new("a (1.0.0)")
      gemlisting.name.should == 'a'
      gemlisting.versions.should == ['1.0.0']
    end
  end
end
