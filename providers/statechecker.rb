#
# Cookbook Name: aem
# Provider:: statechecker
#
require 'open-uri'
require 'timeout'

action :wait do
  puts "\n"
  counter = 0
  def is_loaded? (counter, limit)
    Timeout::timeout(3) {
      open("http://#{node[:hostname]}:#{node[:aem][:port]}/#{node[:aem][:check][:url]}").read.include? "#{node[:aem][:check][:string]}"
    }
  rescue Timeout::Error, Errno::ECONNREFUSED, OpenURI::HTTPError, Errno::ECONNRESET
    if counter >= limit
      puts "Retry limit was reached. Exiting!!!"
      return false
    end
    counter += 1
    puts "Waiting for instance to start at #{node[:hostname]}:#{node[:aem][:port]} ..."; sleep 10 and retry
  end
  if is_loaded?(counter, new_resource.limit)
    puts 'Instance is now up and running...'
  end
end
