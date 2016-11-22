#
# Cookbook Name: aem
# Resource:: statechecker
#


actions :wait

attribute :name, :kind_of => String, :name_attribute => true
attribute :limit, :kind_of => Integer, :default => 90