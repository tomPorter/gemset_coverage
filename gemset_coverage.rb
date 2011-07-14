#!/usr/bin/env ruby
## ToDo:  Go over attr_accessor and decide what attributes need R/W and which just need R access.  Create setters if needed.
## ToDo:  Review methods and determine if need '?' or '!' at end, what should methods return?

class GemHash < Hash
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

  def flag_common_gems!(gemsets)
    self.each_value { |gc_entry| gc_entry.flag_in_all_gemsets gemsets }
    self
  end

  def list_all_gems()
    puts "All Gems:"
    self.sort.each {|k,g| puts g }
  end
  
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
  
  def list_common_gems(gemsets)
    puts "Gems found in all gemsets:"
    self.flag_common_gems!(gemsets)
    common_gems = self.each_value.find_all {|gce| gce.in_all_gemsets? }
    common_gems.each {|g| puts g }
  end  
  
  def list_default_gems()
    puts "Gems found in default gem install location:"
    gems_in_default = self.each_value.find_all {|gce| gce.gemsets_containing.include? 'default' }
    gems_in_default.each {|g| puts g }
  end
end

class GemCoverageEntry
  attr_accessor :name, :gemset_versions, :in_all_gemsets, :gemsets_containing
  def initialize(name)
    @name = name
    @gemset_versions = {}
    @in_all_gemsets = false
    @gemsets_containing = []
  end

  def add_gemset_versions(gemset,versions)
    @gemset_versions[gemset] = versions
    @gemsets_containing << gemset 
  end

  def to_s
    "#{@name}: #{@gemset_versions.inspect}"
  end

  def in_all_gemsets?
    @in_all_gemsets
  end

  def flag_in_all_gemsets(gemsets)
    remaining =  gemsets - @gemsets_containing
    if (remaining.empty? or remaining == ['default'])  
      @in_all_gemsets = true
    end
  end
end

class GemListing
  attr_accessor :name, :versions
  def initialize(gem_listing_line)
    @name = ''
    @versions = []
    add_gem_versions(gem_listing_line)
  end

  def add_gem_versions(line)
    @name, version_string = line.split(/\s/,2)
    @versions = version_string[1..-2].split(/,\s/)
  end
end

def get_gem_list_for_gemset(ruby_version,gemset = '')
  if gemset == ''
    rvm_version = ruby_version
  else
    rvm_version = ruby_version + '@' + gemset
  end
  current_gems = RVM.environment("#{rvm_version}").run_command('gem list')[1].split(/\n/)
  current_gems
end
  
$LOAD_PATH << '~/.rvm/lib'
require 'rvm'
require 'optparse'
options = {}

optparse = OptionParser.new do |opts|
  opts.banner = %{Usage: gemset_coverage.rb [options] [RUBY_VERSION]
       RUBY_VERSION defaults to current RVM ruby version in use.
       One of  '--all_gems', '--gems', '--common', or '--default_warning' is required.}

  opts.on("-g", "--gems gema[,gemb,gemc]",Array, "Gems to look for across gemsets") do |gem_list|
    options[:gems_to_list] = gem_list
  end

  opts.on("-a", "--all_gems","Display all installed gems across all gemsets") do
    options[:display_all_gems] = true
  end

  opts.on("-c", "--common","Display gems found in all gemsets, whether in 'default' or not.") do
    options[:display_common] = true
  end

  opts.on("-d", "--default_warning","Display warning when gems found in 'default'. (Installed outside of a gemset)") do
    options[:default_warning] = true
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely, display inspected gemsets") do |v|
    options[:verbose] = v
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end

begin                                                                                                                                                                                                             
  optparse.parse!
  if options.has_key? :gems_to_list and options.has_key? :display_all_gems
    puts "Error! Cannot use --all_gems and --gems options at the same time."
    puts optparse
    exit
  end                                                                                                                                                                                                 
  if options[:gems_to_list].nil? and options[:display_all_gems].nil? and options[:default_warning].nil? and  options[:display_common].nil?
    puts "Error! Must choose one of  '--all_gems' or '--gems option' or '--common' or '--default_warning'."
    puts optparse
    exit
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts optparse
  exit
end

if ARGV.size == 0
  current_ruby =  RVM.current.environment_name
else
  current_ruby = ARGV[0]
end

gemset_coverage_hash = GemHash.new()

puts "Inspecting default gems for #{current_ruby}" if options[:verbose]
get_gem_list_for_gemset(current_ruby).each do |gem_listing_line| 
  gemset_coverage_hash.update!(gem_listing_line,'default')
end

parent_env = RVM.environment(current_ruby)
current_gemsets = parent_env.gemset_list[1..999]

current_gemsets.each do |gemset|
  puts "Inspecting gemset #{current_ruby}@#{gemset}" if options[:verbose]
  get_gem_list_for_gemset(current_ruby,gemset).each do |gem_listing_line| 
    gemset_coverage_hash.update!(gem_listing_line,gemset)
  end 
end

gemset_coverage_hash.list_all_gems if options[:display_all_gems] 
gemset_coverage_hash.list_desired_gems(options[:gems_to_list]) if options[:gems_to_list]
gemset_coverage_hash.list_common_gems(current_gemsets) if options[:display_common]
gemset_coverage_hash.list_default_gems if options[:default_warning]
