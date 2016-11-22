# default AEM installation attributes
default["aem"]["port"] = 4502
default["aem"]["installation_dir"] = "/data/aem"
default["aem"]["installation_type"] = "author"
default["aem"]["sling_run_modes"] = default["aem"]["installation_type"]
default["aem"]["min_heap"] = 256
default["aem"]["max_heap"] = 1024
default["aem"]["perm_gen"] = 300
default["aem"]["is_reinstall"] = false

default["aem"]["deploy"]["jar_url"] = "file:///shared/cq-quickstart-6.0.jar"
default["aem"]["deploy"]["script_path"] = "/crx-quickstart/bin"
default["aem"]["deploy"]["pid_file_path"] = "/crx-quickstart/conf"

default['aem']['user']['exists'] = false
default["aem"]["username"] = "aem#{node['aem']['installation_type']}"
default["aem"]["groupname"] = default["aem"]["username"]

######
default['aem']['instance']['type'] = "primary"
default['aem']['aemtarmk_instance'] = "aem-#{node["aem"]["installation_type"]}-#{node['aem']['instance']['type']}"
default["aem"]["check"]["url"] = "libs/granite/core/content/login.html"
default["aem"]["check"]["string"] = "QUICKSTART_HOMEPAGE"
default["aem"]["jvm"]["options"] = ''

default['maven']['repositories'] = ['http://repo1.maven.apache.org/maven2']

default['aem']['wait'] = false


default["aem"]["app"]["username"] = "admin"
default["aem"]["app"]["password"] = "admin"
default["aem"]["host"] = "localhost"
default["aem"]["dir_path"] = "#{node['aem']['installation_dir']}/files"
default["aem"]["bundle_url"] = "/system/console/bundles"
default["aem"]["package"]["package_url"] = "/crx/packmgr/service.jsp"
default["aem"]["bundles"]["uninstall_bundles"] = []
default["aem"]["packages"]["install_packages"] = []
default["aem"]["sling"]["install_bundles"] = []