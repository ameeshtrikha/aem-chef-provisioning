maintainer       "Ameesh Trikha"
maintainer_email "ameesh.trikha@gmail.com"
license          "GPL v3"
description      "Installs/Configures AEM"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.0"
name             "aem"

depends "simple_iptables"
depends "nfs"
depends 'maven'
depends "java"
depends "ark"
