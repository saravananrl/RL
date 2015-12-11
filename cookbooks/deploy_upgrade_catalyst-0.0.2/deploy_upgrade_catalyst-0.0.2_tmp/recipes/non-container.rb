#
# Cookbook Name:: deploy_upgrade_catalyst
# Recipe:: default
#
# Copyright 2015, mahendra.shivaswamy
#
# All rights reserved - Do Not Redistribute
#

# Assumes that nexusurl, version attributes are exposed
# GAV - GroupID, ArtifactID, Version
# Version=major.minor.buildID
# Package_name=ArtifactID-Version.zip


url = node["rlcatalyst"]["nexusUrl"]
repo = url.split("/").values_at(6)
repoid = repo[0]
app_name = url.split("/").last.split("-").first  #D4d
version = node["rlcatalyst"]["version"]
package_name = url.split("/").last                    #D4D-2.1.10.zip
package = "#{app_name}" + "-" + "#{version}" #D4D-2.1.10

# Check if Mongo, node, catalyst is installed
# kill node apps if running

ruby_block "check versions" do
   block do

    if File.exists?("/usr/bin/mongod") then
    puts "MongoDB is installed"
    mongod_version=%x`/usr/bin/mongod --version`
    Chef::Log.info("mongod version is #{mongod_version}")
    end

    if File.exists?("/usr/local/bin/node") then
    puts "Node is installed"
    node_version=%x`/usr/local/bin/node --version`
    Chef::Log.info("node version is #{node_version}")
    end

    if File.exists?("/usr/local/bin/npm") then
    puts "Npm is installed"
    npm_version=%x`/usr/local/bin/npm --version`
    Chef::Log.info("npm version is #{npm_version}")
    end
   
   end
end


# install nodjs and mongodb if it doesnot exist

unless File.exists?("/usr/bin/nodejs") then
 include_recipe "nodejs"
end

unless File.exists?("/usr/bin/npm") then
 include_recipe "mongodb"
end

# Deploy app if doesnot exists alreday

if Dir.exists?("#{Chef::Config[:file_cache_path]}/#{repoid}/#{package}")
 include_recipe "deploy_upgrade_catalyst::no_deploy"
elsif
 include_recipe "deploy_upgrade_catalyst::pre_deploy"
end
