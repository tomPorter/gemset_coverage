# @todo Go over :attr_accessor and decide on correct access. 
# @todo Review method names and determine if need '?' or '!' 
# @todo Decide if methods should return nil or self.
module GemCov
  # This class implements a Hash that uses a gem name as a key, 
  # and stores the GemCoverageEntry for that gem name.
  # The GemCoverageEntry for a gem stores the gemsets a gem is 
  # found in and the versions of the gem found in those gemset.
  #
  # Gems matching various conditions can be listed using the list_* methods.
  class GemHash < Hash
  
    # The update! method takes a gem listing line of the kind produced by 
    # the 'gem list' command and adds or updates the GemCoverageEntry 
    # for a given gem name.
    def update!(gem_listing_line,gemset)
      gem_listing = GemListing.new(gem_listing_line)
      if self.has_key? gem_listing.name
        self[gem_listing.name].add_gemset_versions(gemset,gem_listing.versions)
      else
        self[gem_listing.name] = GemCoverageEntry.new(gem_listing.name)
        self[gem_listing.name].add_gemset_versions(gemset,gem_listing.versions)
      end
      self
    end
  
    # List all gems installed across all gemsets, ordered alphabetically.
    def list_all_gems()
      puts "All Gems:"
      self.sort.each {|k,g| puts g }
    end
  
    # List the locations of the gems specified when using the --gems option.  
    def list_desired_gems(list_of_gems)
      gem_list_string = list_of_gems.join(', ')
      puts "Listing selected Gems: #{gem_list_string}"
      list_of_gems.each do |g| 
        if self.has_key? g
          puts self[g]
        else
          puts "#{g} not found in any gemset"
        end
      end
    end
  
    # List all gems flagged as being found in all gemsets
    # If in 'global' gemset, exclude from listing.
    def list_common_gems(gemsets)                                           
      puts "Gems found in all gemsets, but not in 'global':"
      common_gems = self.each_value.find_all do |gce| 
				gce.in_all_gemsets_but_global? gemsets 
			end
      common_gems.each {|g| puts g }
    end  
  
    # List all gems found in the 'default' gemset, i.e. gems installed to 
    # the ruby instance, but not in a gemset.  
    def list_default_gems()                                                               
      puts "Gems found in default gem install location:"
      gems_in_default = self.each_value.find_all do |gce|
        gce.gemsets_containing.include? 'default'
      end
      gems_in_default.each {|g| puts g }
    end
  end
  
  # This class contains information describing which gemsets a gem 
  # is found in and what versions of the gem are installed in each gemset.
  class GemCoverageEntry
    attr_accessor :name, :gemset_versions, :in_all_gemsets, :gemsets_containing
    # Requires a gem name and initializes instance variables.
    def initialize(name)
      @name = name
      @gemset_versions = {}
      @gemsets_containing = []
    end
  
    # Given a gemset name and an Array of installed versions, 
    # adds this to the GemCoverageEntry.
    def add_gemset_versions(gemset,versions)
      @gemset_versions[gemset] = versions
      @gemsets_containing << gemset 
    end
  
    # Returns a string representation of a GemCoverageEntry
    def to_s
      "#{@name}: #{@gemset_versions.inspect}"
    end
  
    # Is gem found in all gemsets for this ruby instance?
    def in_all_gemsets_but_global?(gemsets)
			in_all_gemsets = false
      remaining =  gemsets - @gemsets_containing
      if (remaining.empty? or remaining == ['default'])  
        in_all_gemsets = true
      end
      if gemsets.include? 'global'
				in_all_gemsets = false
			end
      in_all_gemsets
    end
  
  end
  
  # This class holds the gem name and installed versions for a gem.
  class GemListing
    attr_accessor :name, :versions
    # Requires a gem listing line and initializes instance vars.
    def initialize(gem_listing_line)
      @name = ''
      @versions = []
      add_gem_versions(gem_listing_line)
    end
  
    # Given a line produced by running 'gem list' parses it into a gem 
    # name and an array of installed versions.
    def add_gem_versions(line)
      @name, version_string = line.split(/\s/,2)
      @versions = version_string[1..-2].split(/,\s/)
    end
  end
  
  # This class has one purpose: to find all gems in a ruby instance 
  # and an optional gemset. Only contains a class method.
  class GemsetGems
    # Returns a list of installed gems for a given ruby instance and 
    # optionally a specified gemset.
    def GemsetGems.gem_list(ruby_version,gemset = '')
      if gemset == ''
        rvm_version = ruby_version
      else
        rvm_version = ruby_version + '@' + gemset
      end
      current_gems = RVM.environment("#{rvm_version}").run_command('gem list')[1].split(/\n/)
      current_gems
    end
  end  
end
