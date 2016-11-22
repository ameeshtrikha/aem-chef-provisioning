port = node["aem"]["port"]
username = node["aem"]["app"]["username"]
password = node["aem"]["app"]["password"]
host = node["aem"]["host"]
package_url = node["aem"]["package"]["package_url"]
install_packages = node["aem"]["packages"]["install_packages"]


if !install_packages.empty?

  install_packages.each {|package|

    filename = package.split("/").last.chomp("?raw")

    log "Installing package #{filename} from #{package}  "


    execute "Download package #{package}" do
      command "curl -o #{filename} #{package}"
      action :run
    end

    execute "Upload and Install package" do
      command "curl -u #{username}:#{password} -v -F file=@\"#{filename}\" -F force=true -F install=true http://#{host}:#{port}#{package_url}"
      action :run
    end

    execute "Wait 120s" do
      command "sleep 120"
      action :run
    end

  }
end