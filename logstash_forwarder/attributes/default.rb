default['linux']['lsf']['cert_file'] = "logstash-forwarder.crt"
default['linux']['lsf']['ssl_ca'] = "/etc/pki/tls/certs/#{node['linux']['lsf']['cert_file']}"
default['linux']['lsf']['logpath'] = "/var/chef/cache/catalyst/server/logs/*"
default['linux']['lsf']['type'] = "catalyst"

