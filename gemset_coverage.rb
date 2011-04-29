#!/usr/bin/env ruby
class GemCoverage
  attr_accessor :name, :gemset_versions
  def initialize(name)
    @name = name
    @gemset_versions = {}
  end

  def add_gemset_version(gemset,*versions)
    @gemset_versions[gemset] < versions 
  end

  def to_s
    "#{@name}: #{@gemset_versions.inspect}"
  end
end

$LOAD_PATH << '/Users/tporter/.rvm/lib'
require 'rvm'
current_ruby = '1.9.2'
parent_env = RVM.environment(current_ruby)
current_gemsets = parent_env.gemset_list[1..999]
gem_list = {}
current_gemsets.each do |gemset|
  p  "#{current_ruby}@#{gemset}"
  RVM.environment("#{current_ruby}@#{gemset}").rvm :use,  "#{current_ruby}@#{gemset}"
  current_gems = RVM.environment("#{current_ruby}@#{gemset}").run_command('gem list')[1].split(/\n/)
  current_gems.each do |g| 
    p "   #{g}"
     
  end
end

