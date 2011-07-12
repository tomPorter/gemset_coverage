#!/usr/bin/env ruby
class GemHash < Hash
  def update_gem_coverage_hash(gem_entry,gemset)
    if self.has_key? gem_entry.name
      self[gem_entry.name].add_gemset_version(gemset,gem_entry.versions)
    else
      self[gem_entry.name] = GemCoverage.new(gem_entry.name)
      self[gem_entry.name].add_gemset_version(gemset,gem_entry.versions)
    end
  end
end

class GemCoverage
  attr_accessor :name, :gemset_versions
  def initialize(name)
    @name = name
    @gemset_versions = {}
  end

  def add_gemset_version(gemset,versions)
    @gemset_versions[gemset] = versions 
  end

  def to_s
    "#{@name}: #{@gemset_versions.inspect}"
  end
end

class GemEntry
  attr_accessor :name, :versions
  def initialize()
    @name = ''
    @versions = []
  end

  def split_gem_entry(line)
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

  opts.on("-v", "--[no-]verbose", "Run verbosely, display inspected gemsets") do |v|
    options[:verbose] = v
  end
end

begin                                                                                                                                                                                                             
  optparse.parse!
  if options.has_key? :gems_to_list and options.has_key? :display_all_gems
    puts "Error! Cannot use --all_gems and --gems options at the same time."
    puts optparse
    exit
  end                                                                                                                                                                                                 
  if options[:gems_to_list].nil? and options[:display_all_gems].nil?
    puts "Error! Must choose either --all_gems or --gems option."
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
  gem_entry = GemEntry.new()
  gem_entry.split_gem_entry(g)
  gemset_coverage_hash.update_gem_coverage_hash(gem_entry,'default')
end
parent_env = RVM.environment(current_ruby)
current_gemsets = parent_env.gemset_list[1..999]
current_gemsets.each do |gemset|
  puts "Inspecting gemset #{current_ruby}@#{gemset}" if options[:verbose]
  gem_list(current_ruby,gemset).each do |g| 
    gem_entry = GemEntry.new()
    gem_entry.split_gem_entry(g)
    gemset_coverage_hash.update_gem_coverage_hash(gem_entry,gemset)
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


