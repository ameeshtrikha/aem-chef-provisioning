# disable iptables because of https://github.com/rtkwlf/cookbook-simple-iptables/issues/83
#include_recipe "simple_iptables" unless node["platform_family"].include?("suse")
include_recipe "maven"

installation_dir = node["aem"]["installation_dir"]
installation_type = node["aem"]["installation_type"]
port = node["aem"]["port"]
debug_port = node["aem"]["debug_port"]

install_path = "#{installation_dir}/#{installation_type}"
min_heap = node["aem"]["min_heap"]
max_heap = node["aem"]["max_heap"]
perm_gen = node["aem"]["perm_gen"]
aem_jar_url  = node["aem"]["deploy"]["jar_url"]
aem_license_url = node["aem"]["license_url"]
is_reinstall = node["aem"]["is_reinstall"]
jar_name = "cq-#{installation_type}-p#{port}.jar"
script_path = node["aem"]["deploy"]["script_path"]
pid_file_path = node["aem"]["deploy"]["pid_file_path"]
sling_run_modes = node["aem"]["sling_run_modes"]
install_packages = node["aem"]["install_packages"]

unless node['aem']['username'].include? "root" or node['aem']['user']['exists']
  #todo
  include_recipe "aem::user"
end

directory "#{install_path}" do
      mode "0755"
      owner node["aem"]["username"]
      group node["aem"]["groupname"]
      action :create
      recursive true
end

if is_reinstall
	# delete the install directory if its a re-install
	file "#{install_path}/#{jar_name}" do
		action :delete
		notifies :stop, "service[aem-#{installation_type}]", :immediately
		only_if{is_reinstall}
	end
	# delete the install directory if its a re-install
	directory "#{install_path}/crx-quickstart" do
		action :delete
		recursive true
		only_if{is_reinstall}
	end
end

remote_file "#{install_path}/#{jar_name}" do
  source "#{aem_jar_url}"
  owner node["aem"]["username"]
  mode "0755"
  action :create_if_missing
end

if aem_license_url.nil?
    log "No CQ license file supplied"
else
    log "Loading license file from " + aem_license_url
    remote_file "#{install_path}/license.properties" do
        source "#{aem_license_url}"
        owner node["aem"]["username"]
        mode "0755"
        action :create_if_missing
    end
end

is_new_install = !File.exist?("#{install_path}/crx-quickstart")

execute "unpack CQ jar" do
  user node["aem"]["username"]
  command "java -jar #{jar_name} -unpack"
  creates "#{install_path}/crx-quickstart"
  cwd "#{install_path}"
  action :run
end

log "Performing AEM specific setup"

directory "#{install_path}/crx-quickstart/install" do
  mode "0755"
  owner node["aem"]["username"]
  group node["aem"]["groupname"]
  action :create
  recursive true
end

if install_packages != nil

  install_packages.each {|package_location|


    if !package_location.respond_to?(:split)
      # Is a maven structure

      artifact_id = package_location["artifact_id"]
      group_id = package_location["group_id"]
      version = package_location["version"]
      packaging = package_location["packaging"]

      log "Installing maven package #{group_id}:#{artifact_id}:#{version}:#{packaging}"

      maven '#{artifact_id}-#{version}.#{packaging}' do
        group_id  "#{group_id}"
        version   "#{version}"
        packaging "#{packaging}"
        artifact_id "#{artifact_id}"
        dest      "#{install_path}/crx-quickstart/install/"
        #owner node["aem"]["username"]
        mode "0755"
        action :install
      end


    else
      # Is a URL

      log "Installing package from URL #{package_location}"
      filename = package_location.split("/").last.split('?').first
      remote_file "#{install_path}/crx-quickstart/install/#{filename}" do
        source "#{package_location}"
        owner node["aem"]["username"]
        mode "0755"
        action :create_if_missing

      end

    end

  }

end

if is_new_install
  template "#{install_path}/crx-quickstart/bin/start" do
    source "aem_start.erb"
    mode "0755"
    owner node["aem"]["username"]
    variables(
    :min_heap => "#{min_heap}",
    :max_heap => "#{max_heap}",
    :perm_gen => "#{perm_gen}",
    :sling_run_modes => "#{sling_run_modes}",
    :port => "#{port}",
    :debug_port  => "#{debug_port}"
   )
  end
end


execute "chmod " do
  command "chmod -R 777 ./crx-quickstart "
  cwd "#{install_path}"
  action :run
end

case node["platform"]
  when "centos", "redhat"
    if node["platform_version"].include? '6.'
      template "/etc/init.d/aem#{installation_type}" do
        source "aem_rhel6_initd.erb"
        owner node["aem"]["username"]
        mode "0755"
        variables(
            :installation_path => "#{install_path}",
            :user => node["aem"]["username"]
        )
        action :create_if_missing
      end
    elsif node["platform_version"].include? '7.'
      template "/etc/systemd/system/aem#{installation_type}.service" do
        source "aem.service.erb"
        owner node["aem"]["username"]
        mode "0755"
        variables(
            :installation_path => "#{install_path}"
        )
        action :create_if_missing
      end
    end
  when "ubuntu", "debian"
    template "/etc/init.d/aem#{installation_type}" do
      source "aeminstance.erb"
      owner node["aem"]["username"]
      mode "0755"
      variables(
        :installation_type => "#{installation_type}",
        :installation_path => "#{install_path}#{script_path}",
      :aem_pid_file_path => "#{install_path}#{pid_file_path}",
      :min_heap => "#{min_heap}",
      :max_heap => "#{max_heap}",
      :perm_gen => "#{perm_gen}",
      :sling_run_modes => "#{sling_run_modes}",
      :debug_port  => "#{debug_port}"
     )
      action :create_if_missing
    end
  when "opensuse", "suse"
    template "/etc/init.d/aem#{installation_type}" do
      source "aem_suse_initd.erb"
      mode "0755"
      action :create_if_missing
    end
end

service "aem-#{installation_type}" do
  service_name "aem#{installation_type}"
  supports  :stop =>true, :start => true, :status => true
  action [:enable, :start]
end


case node['platform_family']
  when 'rhel'

  simple_iptables_rule "system" do
    Chef::Log.debug("Adding accept iptable rule for port #{port}")
    rule "--proto tcp --dport #{port}"
    jump "ACCEPT"
  end
end

if node['aem']['wait']
  aem_statechecker "aem" do
    action :wait
  end
end

=begin
if is_new_install
  message  = <<-EOS
  
    ****************************************************
    CQ is starting up for the first time. 
    Please allow a few minutes before trying to connect
    with your web browser
    ****************************************************
    
  EOS
  log(message) {level :warn}
end
=end
