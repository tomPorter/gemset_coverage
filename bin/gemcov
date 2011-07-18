#!/usr/bin/env ruby
# The program helps explore the gems found in the defined gemsets for an RVM ruby instance.
#
# - You can list all installed gems and which gemsets they are installed in using the --all_gems option. 
#
# - You can search all gemsets for specific gems using the --gems gema[,gemb,gemc] option.
# - You can search for all gems installed for a ruby instance but NOT installed in a gemset using the --default_warning option.
# - You can find any gems that occur in all gemsets using the --common option.
#
# Author::    Tom Porter  (mailto:thomas.porter@acm.org)
# Copyright:: Copyright (c) 2011 Thomas Porter
# License::   Distributes under the same terms as Ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << '~/.rvm/lib'
require 'gemcov'
['rvm','optparse'].each do |g|
  begin 
    require g
  rescue LoadError => e
    raise unless e.message.include? g
    if g == 'rvm'
      puts "Do you have RVM installed?  If not please do so."
    else
      puts "Required module not found, please install '#{g}'"
    end
    exit
  end
end

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

gemset_coverage_hash = GemCov::GemHash.new()

puts "Inspecting default gems for #{current_ruby}" if options[:verbose]
GemCov::GemsetGems.gem_list(current_ruby).each do |gem_listing_line| 
  gemset_coverage_hash.update!(gem_listing_line,'default')
end

parent_env = RVM.environment(current_ruby)
current_gemsets = parent_env.gemset_list[1..999]

current_gemsets.each do |gemset|
  puts "Inspecting gemset #{current_ruby}@#{gemset}" if options[:verbose]
  GemCov::GemsetGems.gem_list(current_ruby,gemset).each do |gem_listing_line| 
    gemset_coverage_hash.update!(gem_listing_line,gemset)
  end 
end

gemset_coverage_hash.list_all_gems if options[:display_all_gems] 
gemset_coverage_hash.list_desired_gems(options[:gems_to_list]) if options[:gems_to_list]
gemset_coverage_hash.list_common_gems(current_gemsets) if options[:display_common]
gemset_coverage_hash.list_default_gems if options[:default_warning]
