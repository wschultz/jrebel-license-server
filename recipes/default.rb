#
# Cookbook Name:: jrebel-license-server
# Recipe:: default
#
# Copyright 2013, Wil Schultz
#

# Requires oracle.
include_recipe "java::oracle"

# Make some vars, looks nicer.
install_path   = node["jrebel-license-server"]["install_path"] # /opt/license-server
source_url     = node["jrebel-license-server"]["source_url"]   # http://dl.zeroturnaround.com/license-server/license-server-2.0.7.zip
version        = node["jrebel-license-server"]["version"]      # 2.0.7
jrebel_user    = node["jrebel-license-server"]["jrebel_user"]      

# Add a nice user to run as.
user "#{jrebel_user}" do
  comment "jrebel license server"
  shell "/bin/bash"
  home "#{install_path}"
  supports :manage_home => true
end

# Make sure zip is installed. Stoopid zip files.
execute "add_package" do
  command "aptitude install zip -y"
end

# Install the jrebel-license-server
template "/etc/init.d/jrebel-license-server" do
  source "jrebel-license-server.init.erb"
  owner "root"
  group "root"
  mode  00755
  variables(
    :user => jrebel_user,
    :base => install_path
  )
  action :create
end

unless File.exists?("#{install_path}/bin/license-server.sh")

  remote_file "jrebel-license-server" do
    path "#{Chef::Config[:file_cache_path]}/license-server.zip"
    source "#{source_url}/license-server-#{version}.zip"
  end
  
  execute "unzip-jrebel-license-server" do
    cwd Chef::Config[:file_cache_path]
    command "unzip license-server.zip"
  end
  
  execute "install-jrebel-license-server" do
    command "cp -R #{Chef::Config[:file_cache_path]}/license-server #{install_path}"
  end

  execute "chown-jrebel-license-server" do
    command "chown -R #{jrebel_user}:#{jrebel_user} #{install_path}"
  end

end

service "jrebel-license-server" do
  supports :restart => true
  action [:enable, :start]
end

