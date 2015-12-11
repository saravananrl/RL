#
# Cookbook Name:: tom_cat
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


package 'java-1.8.0-openjdk.x86_64' do
	action :install
end

package 'wget' do
	action :install
end

directory '/opt/tomcat' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

bash 'install_something' do
  user 'root'
  cwd '/opt/tomcat'
  install_path = '/opt/tomcat/webapps'
  code <<-EOH
  wget http://mirror.sdunix.com/apache/tomcat/tomcat-7/v7.0.65/bin/apache-tomcat-7.0.65.tar.gz
  tar -xvf apache-tomcat-7.0.65.tar.gz -C /opt/tomcat --strip-components=1
  EOH
  not_if { ::File.exists?(install_path) }
end

cookbook_file "/etc/init.d/tomcat" do
  source "tomcat_init"
  mode "0755"
end

service 'tomcat' do
  supports :status => true
  action [ :enable, :start ]
end

execute 'tomcat_start ' do
  command 'service tomcat start'
end

service 'iptables' do
  action [ :disable, :stop ]
end


