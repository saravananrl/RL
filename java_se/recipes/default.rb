if node['java_se']['skip']
  Chef::Log.warn('Skipping install of Java SE!')
else
  arch = node['kernel']['machine'] =~ /x86_64/ ? 'x64' : 'i586'
  arch = 'i586' if node['java_se']['force_i586'] && !platform?('mac_os_x')
  node.set['java_se']['arch'] = arch

  node.set['java_se']['jdk_version'] = node['java_se']['version'].sub(/^\d+\.(\d+).*?_(.*)$/, '\1u\2')

  include_recipe 'java_se::_download_java'

  case node['platform_family']
  when 'mac_os_x'
    include_recipe 'java_se::_macosx_install'
  when 'windows'
    include_recipe 'java_se::_windows_install'
  else
    include_recipe 'java_se::_linux_install'
  end
end
