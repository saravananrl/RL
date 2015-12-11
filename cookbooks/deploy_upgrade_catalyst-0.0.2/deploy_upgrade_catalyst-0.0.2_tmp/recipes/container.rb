
# Cookbook Name:: container
# Recipe:: default
#
# Copyright 2015, Relevance Lab pvt ltd.
#
# All rights reserved - Do Not Redistribute
#

catalystCallbackUrl = node["deploy_upgrade_catalyst"]["catalystCallbackUrl"]
target_dir = node["deploy_upgrade_catalyst"]["target_dir"]
url = node["rlcatalyst"]["nexusUrl"]
version = node["rlcatalyst"]["version"]
download_dir = node["deploy_upgrade_catalyst"]["download_dir"]
containerId = node["rlcatalyst"]["containerId"]
containerPort = node["rlcatalyst"]["containerPort"]
repoid = url.split("repositories/")[1].split("/")[0]
package_type = url.split(".").last               #zip
app_name = url.split("/").last.split("-").first  #D4d
package_name = url.split("/").last                    #D4D-2.1.10.zip
version = url.split("/").last.split("-").last.split(".").first(3).join(".") #2.1.10
package = "#{app_name}" + "-" + "#{version}"
puts "url :: #{url}"
puts "version :: #{version}"
puts "package_type :: #{package_type}"
puts "app_name :: #{app_name}"
puts "package_name :: #{package_name}"
puts "target_dir:: #{target_dir}"
puts "catalystCallbackUrl :: #{catalystCallbackUrl}"
puts "containerID :: #{containerId}"
puts "containerPort :: #{containerPort}"


docker_installation 'default' do
  repo 'main'
  action :create
end

docker_installation_script 'default' do
  repo 'main'
  action :create
end

docker_installation_package 'default' do
  version '1.9.1'
  action :create
end

directory "/root/.docker" do
user "root"
group "root"
action :nothing
end.run_action(:create)

template "/root/.docker/config.json" do
source "config.json.erb"
user "root"
group "root"
mode 0644
action :nothing
end.run_action(:create)


docker_image 'relevancelab/catalysttest' do
  tag 'latest'
  action :pull
end

checkRunningPort = %x(docker ps | grep #{containerPort})
puts "Running Container with Port: #{checkRunningPort}"

if !checkRunningPort.empty? then
  puts "Port #{containerPort} is already running.Please choose different port."
  exit
end


container_exists = %x(docker ps | grep #{containerId})
if container_exists.empty? then

#a = 3000
#b = 3020

#portnum = Random.new.rand(a..b) 
#portnum = '3001'
portnum = "#{containerPort}"

docker_container "#{containerId}" do
  repo 'relevancelab/catalysttest'
  tag 'latest'
  command "/bin/bash"
  tty true
  #Let docker pick the port
  #port "3001"
  port "#{portnum}:3001"
  #host_name 'www'
  #domain_name 'computers.biz'
  #env 'FOO=bar'
  #binds [ '/some/local/files/:/etc/nginx/conf.d' ]
  action [:run, :start]
end  

puts "Waiting for the container to run"
sleep 20

=begin
directory "#{Chef::Config[:file_cache_path]}/#{repoid}" do
action :nothing
not_if {Dir.exists?("#{Chef::Config[:file_cache_path]}/#{repoid}")}
end.run_action(:create)

directory "#{Chef::Config[:file_cache_path]}/#{repoid}/#{package}" do
action :nothing
not_if {Dir.exists?("#{Chef::Config[:file_cache_path]}/#{repoid}/#{package}")}
end.run_action(:create)
=end
=begin
directory "#{download_dir}/#{app_name}" do
action :delete
recursive true
only_if {Dir.exists?("#{download_dir}/#{app_name}")}
end

remote_file "#{download_dir}/#{package_name}" do
  owner 'root'
  group 'root'
  mode '0644'
  source "#{url}"
end

execute "unzip" do
  user "root"
  group "root"
  cwd "#{download_dir}"
  action :run
  command "unzip #{package_name}"
end

=end

template '/tmp/installcat.sh' do
  source 'installcat.sh.erb'
  owner 'root'
  group 'root'
  mode '0755'
  only_if {Dir.exists?("/tmp")}
  variables ({
        :repoid => "#{repoid}",
        :package => "#{package}",
        :target => "#{target_dir}",
        :url => "#{url}",
        :app_name => "#{app_name}",
        :package_name => "#{package_name}"
    })
end

bash "copy script" do
cwd "/tmp"
code <<-EOH
cat /tmp/installcat.sh | docker exec -i #{containerId} sh -c 'cat > /tmp/installcat.sh'
docker exec #{containerId} sh /tmp/installcat.sh
EOH
ignore_failure false
end


=begin
bash "Deploy artifact #{package} to container #{containerId}" do
cwd "/tmp"
code <<-EOH
docker cp #{download_dir}/#{app_name} #{containerId}:#{target_dir}/#{repoid}/#{package}/
EOH
ignore_failure true
end

template '/tmp/deploy.sh' do
  source 'deploy.sh.erb'
  owner 'root'
  group 'root'
  mode '0755'
  only_if {Dir.exists?("/tmp")}
  variables ({
        :repoid => "#{repoid}",
        :package => "#{package}",
        :target => "#{target_dir}"
    })
end

bash "copy script" do
cwd "/tmp"
code <<-EOH
cat /tmp/deploy.sh | docker exec -i #{containerId} sh -c 'cat > /tmp/deploy.sh'
docker exec #{containerId} sh /tmp/deploy.sh
EOH
ignore_failure true
end
=end

ruby_block "Update App data" do
        block do
                node.default['app_data_handler']['catalystCallbackUrl'] = "#{catalystCallbackUrl}"
                node.default['app_data_handler']['app']['containerId'] = "#{containerId}"
                node.default['app_data_handler']['app']['applicationType'] = "Container"
                node.default['app_data_handler']['app']['applicationName'] = "#{repoid}"
                # version =  JSON.load(File.read("#{target_dir}/version.json"))["version"]
                node.default['app_data_handler']['app']['applicationVersion'] = "#{version}"
                node.default['app_data_handler']['app']['applicationInstanceName'] = "Supercatalyst"
        end
end

include_recipe "app_data_handler"

else

puts "container already exists, please choose diffrent name/id"

end
