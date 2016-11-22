# Restarts AEM
installation_type = node["aem"]["installation_type"]
port = node["aem"]["port"]

execute "Stop aem#{installation_type}" do
  command "service aem#{installation_type} stop"
end

execute "Start aem#{installation_type}" do
  command "service aem#{installation_type} start"
end

aem_statechecker "aem" do
    action :wait
end