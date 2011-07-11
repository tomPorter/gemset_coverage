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

def print_gems(ruby_version,gemset = '')
  if gemset == ''
    p  "#{ruby_version} default"
    RVM.environment("#{ruby_version}").rvm :use,  "#{ruby_version}"
  else
    p  "#{ruby_version}@#{gemset}"
    RVM.environment("#{ruby_version}@#{gemset}").rvm :use,  "#{ruby_version}@#{gemset}"
  end
  current_gems = RVM.environment("#{ruby_version}@#{gemset}").run_command('gem list')[1].split(/\n/)
  current_gems.each do |g| 
    p "   #{g}"
     
  end
end

$LOAD_PATH << '~/.rvm/lib'
require 'rvm'
current_ruby = '1.9.2'
parent_env = RVM.environment(current_ruby)
print_gems(current_ruby)
current_gemsets = parent_env.gemset_list[1..999]
gem_list = {}
current_gemsets.each do |gemset|
  print_gems(current_ruby,gemset)
end

