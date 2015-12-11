name             'deploy_upgrade_catalyst'
maintainer       'mahendra.shivaswamy'
maintainer_email 'mahendra.shivaswamy@outlook.com'
license          'All rights reserved'
description      'Installs/Configures nexus_deploy_rlcatalyst'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.2'

depends 'git'
depends 'mongodb'
depends 'nodejs'
depends 'build-essential'
depends 'docker'

# Changes Made by Gobinda Das
depends "app_data_handler", "= 0.1.3"

attribute 'rlcatalyst/nexusUrl',
  :display_name => "Nexus Repo Url",
  :description => "Nexus Repo Url",
  :default => "url"

attribute 'rlcatalyst/version',
  :display_name => "Version",
  :description => "Version of the App to be deployed",
  :default => "version"

attribute 'rlcatalyst/containerId',
  :display_name => "Container Id",
  :description => "Container Id of already running container",
  :default => "NA"

attribute 'rlcatalyst/containerPort',
  :display_name => "Container Port",
  :description => "Container port to deploy application newly",
  :default => "NA"
