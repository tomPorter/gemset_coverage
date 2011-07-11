#!/usr/bin/env ruby
class GemCoverage
  attr_accessor :name, :gemset_versions
  def initialize(name)
    @name = name
    @gemset_versions = {}
  end

  def add_gemset_version(gemset,*versions)
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
    @versions = version_string[1..-2].split(',')
	end
end

def gem_list(ruby_version,gemset = '')
  ## ToDo: currently returns list of strings in "gem_name (ver1, ver2, ver3)" format
  ## ToDo: Need to break out into gem names and list of versions, then flesh out
  ## ToDo: classes.
  if gemset == ''
    rvm_version = ruby_version
  else
    rvm_version = ruby_version + '@' + gemset
  end
  current_gems = RVM.environment("#{rvm_version}").run_command('gem list')[1].split(/\n/)
  current_gems
end

def update_gem_coverage_hash(gc_hash,gem_entry,gemset)
  if gc_hash.has_key? gem_entry.name
    gc_hash[gem_entry.name].add_gemset_version(gemset,gem_entry.versions)
  else
    gc_hash[gem_entry.name] = GemCoverage.new(gem_entry.name)
    gc_hash[gem_entry.name].add_gemset_version(gemset,gem_entry.versions)
  end
end

$LOAD_PATH << '~/.rvm/lib'
require 'rvm'
gemset_coverage_hash = {}
current_ruby = '1.9.2'
p current_ruby
#gem_list(current_ruby).each { |g| p "  #{g}" }
gem_list(current_ruby).each do |g| 
  gem_entry = GemEntry.new()
  gem_entry.split_gem_entry(g)
  update_gem_coverage_hash(gemset_coverage_hash,gem_entry,'default')
end
parent_env = RVM.environment(current_ruby)
current_gemsets = parent_env.gemset_list[1..999]
current_gemsets.each do |gemset|
  p "#{current_ruby}@#{gemset}"
  gem_list(current_ruby,gemset).each do |g| 
    gem_entry = GemEntry.new()
    gem_entry.split_gem_entry(g)
    update_gem_coverage_hash(gemset_coverage_hash,gem_entry,gemset)
  end 
end
#p gemset_coverage_hash
p gemset_coverage_hash['activemodel']

