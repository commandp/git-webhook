#!/usr/bin/env ruby
require 'json'
require 'yaml'
require 'net/http'

# get repo name
repo = ARGV[0]

# get branch name
ref = ARGV[1]
ref =~ /refs\/heads\/(.*)/
branch = $1

pwd = Dir.pwd

config_file = File.dirname(__FILE__) + "/config.yml"
repos = YAML.load(open(config_file){|f| f.read})

# 更新本地 git repor
if File.directory?("/home/git/#{repo}.git")
  %x{su - git -c 'cd /home/git/#{repo}.git && git remote update --prune'}
else
  %x{su - git -c 'cd /home/git/ && git clone --mirror git@github.com:#{repos[repo]['owner']}/#{repo}.git'}
end

puts "#{repo}/#{branch} #{repos[repo].inspect}"

if ci_endpoint = ( repos[repo]["ci_endpoints"] && repos[repo]["ci_endpoints"][branch])
  uri = URI(ci_endpoint)
  puts "http get #{uri}"
  puts Net::HTTP.get(uri).inspect # => String
end
