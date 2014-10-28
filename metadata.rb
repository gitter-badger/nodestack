# Encoding: utf-8
name 'nodestack'
maintainer 'Rackspace'
maintainer_email 'rackspace-cookbooks@rackspace.com'
license 'Apache 2.0'
description 'Installs/Configures nodestack'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '2.2.1'
supports 'ubuntu', '= 12.04'
supports 'ubuntu', '= 14.04'
supports 'rhel', '>= 6.0'

depends 'apt'
depends 'mysql'
depends 'mysql-multi'
depends 'database'
depends 'chef-sugar'
depends 'apt'
depends 'mysql'
depends 'database'
depends 'chef-sugar'
depends 'elasticsearch'
depends 'apache2', '~> 1.10'
depends 'memcached'
depends 'openssl'
depends 'redisio'
depends 'varnish'
depends 'rackspace_gluster'
depends 'platformstack'
depends 'mongodb'
depends 'build-essential'
depends 'java'
depends 'yum'
depends 'git'
depends 'nodejs'
depends 'ssh_known_hosts'
depends 'application'
depends 'magic_shell'
depends 'pg-multi'
depends 'newrelic'
depends 'logrotate'
depends 'logstash_commons'
depends 'sudo'
