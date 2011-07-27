require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Gem Listing" do
  it "should add gem versions" do
    gemlisting = GemCov::GemListing.new("a (1.0.0)")
    gemlisting.name.should == 'a'
    gemlisting.versions.should == ['1.0.0']
  end
end

describe "Gem Coverage Entry" do
  it "A new instance should have a name" do 
    gce = GemCov::GemCoverageEntry.new('aGem')
    gce.name.should == 'aGem'
    gce.gemset_versions.should == {}
    gce.gemsets_containing.should == []
  end
  it "should be able to add gemsets and associated versions" do 
    gce = GemCov::GemCoverageEntry.new('aGem')
    versions = ['1.0.0','1.1.0']
    gemset_name = 'default'
    gce.add_gemset_versions(gemset_name,versions)
    gce.gemset_versions.include?(gemset_name).should == true
    gce.gemset_versions[gemset_name].should == versions
  end
  it "should identfy when a gem exists in all gemsets but the global one" do 
    gce = GemCov::GemCoverageEntry.new('aGem')
    versions = ['1.0.0']
    global_name = 'global'
    all_gemsets = ['global','default']
    gce.add_gemset_versions(global_name,versions)
    gce.in_all_gemsets_but_global?(all_gemsets).should == false
  end
end
