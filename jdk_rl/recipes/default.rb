#
# Cookbook Name:: jdk_rl
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

Architecture = node[:kernel][:machine]
Distro = node["platform_family"]
Java_home = '/usr/lib/jvm/java'
Java_minor_version = 66

if Architecture == "x86_64"
	arch_bit = 'x64'
else
	arch_bit = 'i586'
end


bundle_name = "jdk-8u#{Java_minor_version}-linux-#{arch_bit}.tar.gz"




if Architecture == "x86_64"
    node.run_state['Download_url'] = "http://download.oracle.com/otn-pub/java/jdk/8u#{Java_minor_version}-b17/#{bundle_name}"
else
    node.run_state['Download_url'] = "http://download.oracle.com/otn-pub/java/jdk/8u#{Java_minor_version}-b17/#{bundle_name}"
end


package 'wget' do
	action :install
end


script 'Download and install JDK' do
	interpreter "bash"
	install_path = #{Java_home}
	code <<-EOH
	cd /tmp
	mkdir #{Java_home}
	wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" #{node.run_state['Download_url']}
	tar -xvf #{bundle_name} -C #{Java_home} --strip-components=1
	EOH
	not_if { ::File.exists?(install_path) }
end
