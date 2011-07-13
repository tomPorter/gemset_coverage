#!/usr/bin/env ruby
## ToDo:  Decide if a warning is needed when gems are found installed in 'default'
## ToDo:  Figure out how to handle GemHash.flag_gems_found_in_all_gemsets; should 'default' count or not?

class GemHash < Hash
  def update_gem_coverage_hash(gem_listing,gemset)
    if self.has_key? gem_listing.name
      self[gem_listing.name].add_gemset_versions(gemset,gem_listing.versions)
    else
      self[gem_listing.name] = GemCoverageEntry.new(gem_listing.name)
      self[gem_listing.name].add_gemset_versions(gemset,gem_listing.versions)
    end
  end

	def flag_gems_found_in_all_gemsets(gemsets)
	  self.each_value do |gc_entry|
      if gemsets == gc_entry.gemsets_containing
        gc_entry.in_all_gemsets = true
      end
    end	
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
end

class GemListing
  attr_accessor :name, :versions
  def initialize()
    @name = ''
    @versions = []
  end

  def add_gem_versions(line)
    @name, version_string = line.split(/\s/,2)
    @versions = version_string[1..-2].split(/,\s/)
	end
end

def gem_list(ruby_version,gemset = '')
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
       Either '--all_gems' or '--gems' option is required.}

  opts.on("-g", "--gems gema[,gemb,gemc]",Array, "Gems to look for across gemsets") do |gem_list|
    options[:gems_to_list] = gem_list
  end

  opts.on("-a", "--all_gems","Display all installed gems across all gemsets") do
    options[:display_all_gems] = true
  end

  opts.on("-c", "--common","Display gems found in all gemsets, NOT including default.") do
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
puts "Inspecting default gems for #{current_ruby}" if options[:verbose]

gemset_coverage_hash = GemHash.new()
gem_list(current_ruby).each do |g| 
  gem_listing = GemListing.new()
  gem_listing.add_gem_versions(g)
  gemset_coverage_hash.update_gem_coverage_hash(gem_listing,'default')
end
parent_env = RVM.environment(current_ruby)
current_gemsets = parent_env.gemset_list[1..999]
current_gemsets.each do |gemset|
  puts "Inspecting gemset #{current_ruby}@#{gemset}" if options[:verbose]
  gem_list(current_ruby,gemset).each do |g| 
    gem_listing = GemListing.new()
    gem_listing.add_gem_versions(g)
    gemset_coverage_hash.update_gem_coverage_hash(gem_listing,gemset)
  end 
end
if options[:display_all_gems]
  gemset_coverage_hash.each_value {|g| puts g }
else
  if  options[:gems_to_list]
    options[:gems_to_list].each do |g| 
      if gemset_coverage_hash.has_key? g
        puts gemset_coverage_hash[g]
      else
        puts "#{g} not found in any gemset"
      end
    end
  end
end
if options[:display_common]
  puts "Gems found in all gemsets:"
  gemset_coverage_hash.flag_gems_found_in_all_gemsets(current_gemsets)
  common_gems = gemset_coverage_hash.each_value.find_all {|gce| gce.in_all_gemsets? }
  common_gems.each {|g| p g }
end
if options[:default_warning]
  puts "Gems found in default gem install location:"
  gems_in_default = gemset_coverage_hash.each_value.find_all {|gce| gce.gemsets_containing.include? 'default' }
  gems_in_default.each {|g| p g }
end
