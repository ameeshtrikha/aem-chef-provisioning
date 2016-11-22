port = node["aem"]["port"]
username = node["aem"]["app"]["username"]
password = node["aem"]["app"]["password"]
host = node["aem"]["host"]
bundle_url = node["aem"]["bundle_url"]
install_bundles = node["aem"]["sling"]["install_bundles"]
uninstall_bundles = node["aem"]["bundles"]["uninstall_bundles"]

if !uninstall_bundles.empty?

  uninstall_bundles.each {|bundle|

    bundlename = bundle

    log "Uninstalling bundle #{bundle} "

    execute "Uninstall Bundle" do
      command "curl -u #{username}:#{password} -v -F action=uninstall http://#{host}:#{port}#{bundle_url}/#{bundle}"
      action :run
    end
  }

  execute "Refresh Bundle packages" do
    command "curl -u admin:admin -F action=refreshPackages http://#{host}:#{port}/system/console/bundles"
    action :run
  end
end


if !install_bundles.empty?

  install_bundles.each {|bundle|

    filename = bundle.split("/").last.chomp("?raw")

    log "Installing bundle #{filename}  from #{bundle} "


    execute "Download bundle from #{bundle}" do
      command "curl -o #{filename} #{bundle}"
      action :run
    end

    execute "Install Bundle" do
      command "curl -u #{username}:#{password} -v -F action=install -F bundlestart=start -F bundlestartlevel=20 -F bundlefile=@\"#{filename}\" http://#{host}:#{port}#{bundle_url}"
      action :run
    end
  }

  execute "Refresh Bundle packages" do
    command "curl -u admin:admin -F action=refreshPackages http://#{host}:#{port}/system/console/bundles"
    action :run
  end
end