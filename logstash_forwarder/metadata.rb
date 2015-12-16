name             'logstash_forwarder'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures logstash_forwarder'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

attribute 'linux/lsf/logpath',
  :display_name => "Log Path",
  :description => "Please specify Log Path",
  :default => ''
  
  
attribute 'linux/lsf/type',
  :display_name => "Select Log to Monitor",
  :description => "Please specify Log to Monitor",
  :choice => [
    'catalyst',
	'tomcat'],
  :default => "catalyst"
