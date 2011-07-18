#--
# TODO Go over attr_accessor and decide what attributes need R/W and which just need R access.  Create setters if needed.
# TODO Review methods and determine if need '?' or '!' at end, what should methods return?
#++
module GemCov
  # This class implements a Hash that uses a gem name as a key, and stores the GemCoverageEntry for that gem name.
  # The GemCoverageEntry for a gem stores the gemsets a gem is found in and the versions of the gem
  # found in those gemset.
  #
  # Gems matching various conditions can be listed using the list_* methods.
  class GemHash < Hash
  
    # The update! method takes a gem listing line of the kind produced by the 'gem list' command
    # and adds or updates the GemCoverageEntry for a given gem name.
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
  
    # Flag all entries in the GemHash that are found in all gemsets for the ruby instance.
    # If a gem is installed in all gemsets but not in the @global gemset, then it could be
    # installed in the @global gemset instead.
    def flag_common_gems!(gemsets)
      self.each_value { |gc_entry| gc_entry.flag_in_all_gemsets gemsets }
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
  
  	# List all gems flagged as being found in all gemsets by the flag_common_gems! method.  
    def list_common_gems(gemsets)                                           
      puts "Gems found in all gemsets:"
      self.flag_common_gems!(gemsets)
      common_gems = self.each_value.find_all {|gce| gce.in_all_gemsets? }
      common_gems.each {|g| puts g }
    end  
  
  	# List all gems found in the 'default' gemset, i.e. gems installed to the ruby instance, but
  	# not in a gemset.  
    def list_default_gems()                                                               
      puts "Gems found in default gem install location:"
      gems_in_default = self.each_value.find_all {|gce| gce.gemsets_containing.include? 'default' }
      gems_in_default.each {|g| puts g }
    end
  end
  
  # This class contains information describing which gemsets a gem is found in
  # and what versions of the gem are installed in each gemset.
  class GemCoverageEntry
    attr_accessor :name, :gemset_versions, :in_all_gemsets, :gemsets_containing
  	# Requires a gem name and initializes instance variables.
    def initialize(name)
      @name = name
      @gemset_versions = {}
      @in_all_gemsets = false
      @gemsets_containing = []
    end
  
  	# Given a gemset name and an Array of installed versions, adds this to the GemCoverageEntry.
    def add_gemset_versions(gemset,versions)
      @gemset_versions[gemset] = versions
      @gemsets_containing << gemset 
    end
  
    # Returns a string representation of a GemCoverageEntry
    def to_s
      "#{@name}: #{@gemset_versions.inspect}"
    end
  
    # Is gem found in all gemsets for this ruby instance?
    def in_all_gemsets?
      @in_all_gemsets
    end
  
  	# Given a list of all gemsets for a ruby instance, sets @in_all_gemsets if
  	# the gem is found in all the gemsets.
    def flag_in_all_gemsets(gemsets)
      remaining =  gemsets - @gemsets_containing
      if (remaining.empty? or remaining == ['default'])  
        @in_all_gemsets = true
      end
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
  
  	# Given a line produced by running 'gem list' parses it into a gem name and 
  	# an array of installed versions.
    def add_gem_versions(line)
      @name, version_string = line.split(/\s/,2)
      @versions = version_string[1..-2].split(/,\s/)
    end
  end
  
  # This class has one purpose: to find all gems in a ruby instance and an optional gemset.
  # Only contains a class method.
  class GemsetGems
    # Returns a list of installed gems for a given ruby instance and optionally a specified gemset.
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