#
# Cookbook Name:: logstash-forwarder
# Recipe:: default
#
#
# All rights reserved - Do Not Redistribute
#

execute "Install Logstash" do
	command "
		echo 'deb http://packages.elasticsearch.org/logstashforwarder/debian stable main' | sudo tee /etc/apt/sources.list.d/logstashforwarder.list
		wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
		apt-get update
		apt-get install logstash-forwarder"
end

execute "Create logstash directory" do
	command "mkdir -p /etc/logstash-forwarder 
			 mv /etc/logstash-forwarder.conf /etc/logstash-forwarder/logstash-forwarder.conf_bkp"
#not_if do ::File.exists?('/etc/logstash-forwarder.conf') end
end 

=begin
execute "Create logstash directory" do
	command "mkdir -p /etc/logstash-forwarder"
end 
=end
execute "Create Directory for certificate" do
	command "mkdir -p /etc/pki/tls/certs"
not_if { ::Dir.exists?("/etc/pki/tls/certs")}	 
end 



bash "changing logstash config path" do
	code <<-EOH
	sudo sed -i 's/logstash-forwarder.conf/logstash-forwarder/g' /etc/init.d/logstash-forwarder
  EOH
end

template "#{node['linux']['lsf']['ssl_ca']}" do
  source "logstash-forwarder.crt.erb"
  mode '0644'
end




template "/etc/logstash-forwarder/network.conf" do
  source "network.cfg.erb"
  mode '0644'
end


configtype = "#{node['linux']['lsf']['type']}"


if "#{configtype}" == "catalyst"
	template "/etc/logstash-forwarder/catalyst.conf" do
	  source "catalyst.cfg.erb"
	  mode '0644'
	end
end

if "#{configtype}" == "tomcat"
	template "/etc/logstash-forwarder/tomcat.conf" do
	  source "tomcat.cfg.erb"
	  mode '0644'
	end
end

service "logstash-forwarder" do
	action :restart
end



