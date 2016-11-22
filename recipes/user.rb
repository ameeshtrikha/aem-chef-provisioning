user node['aem']['username'] do
  supports :manage_home => true
  comment "AEM #{node['aem']['username']} system user"
  home "/home/#{node['aem']['username']}"
  shell "/bin/bash"
end

group node['aem']['groupname'] do
    action :create
end


directory "/home/#{node['aem']['username']}/.ssh" do
  owner node['aem']['username']
  mode 0700
end

cookbook_file "Private key" do
  path "/home/#{node['aem']['username']}/.ssh/id_rsa"
  mode 0600
  source "id_rsa"
  owner node['aem']['username']
end

cookbook_file "Add public key to authorized_keys" do
  path "/home/#{node['aem']['username']}/.ssh/authorized_keys"
  mode 0600
  source "authorized_keys"
  owner node['aem']['username']
end