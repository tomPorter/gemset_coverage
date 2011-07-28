require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
module GemCov
  describe "Gem Coverage Entry" do
    it "A new instance should have a name" do 
      gce = GemCoverageEntry.new('aGem')
      gce.name.should == 'aGem'
      gce.gemset_versions.should == {}
      gce.gemsets_containing.should == []
    end
    it "should be able to add gemsets and associated versions" do 
      gce = GemCoverageEntry.new('aGem')
      versions = ['1.0.0','1.1.0']
      gemset_name = 'default'
      gce.add_gemset_versions(gemset_name,versions)
      gce.gemset_versions.include?(gemset_name).should == true
      gce.gemset_versions[gemset_name].should == versions
    end
    it ".all_gemsets_but_global? should return 'true' when a gem exists in all gemsets, the default ruby instance, but not in 'global'" do 
      gce = GemCoverageEntry.new('aGem')
      versions = ['1.0.0']
      all_gemsets = ['another_gemset','my_gemset','default']
      all_gemsets.collect {|gs| gce.add_gemset_versions(gs,versions) }
      gce.in_all_gemsets_but_global?(all_gemsets).should == true
    end
    it ".all_gemsets_but_global? should return 'true' when a gem exists in all gemsets but not in 'global'" do 
      gce = GemCoverageEntry.new('aGem')
      versions = ['1.0.0']
      all_gemsets = ['another_gemset','my_gemset']
      all_gemsets.collect {|gs| gce.add_gemset_versions(gs,versions) }
      gce.in_all_gemsets_but_global?(all_gemsets).should == true
    end
    it ".all_gemsets_but_global? should return 'false' when a gem exists in all gemsets and the global one" do 
      gce = GemCoverageEntry.new('aGem')
      versions = ['1.0.0']
      all_gemsets = ['another_gemset','my_gemset','global']
      all_gemsets.collect {|gs| gce.add_gemset_versions(gs,versions) }
      gce.in_all_gemsets_but_global?(all_gemsets).should == false
    end
    it ".all_gemsets_but_global? should return 'false' when a gem does not exist in all gemsets" do 
      gce = GemCoverageEntry.new('aGem')
      versions = ['1.0.0']
      my_name = 'mygemset'
      all_gemsets = ['agemset','anothergemset','mygemset']
      gce.add_gemset_versions(my_name,versions)
      gce.in_all_gemsets_but_global?(all_gemsets).should == false
    end
    it ".all_gemsets_but_global? should return 'false' when a gem exists only in 'global'" do 
      gce = GemCoverageEntry.new('aGem')
      versions = ['1.0.0']
     my_name = 'global'
      all_gemsets = ['global']
      gce.add_gemset_versions(my_name,versions)
      gce.in_all_gemsets_but_global?(all_gemsets).should == false
    end
  end
end
