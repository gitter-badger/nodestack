nodestack Cookbook
==================
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/rackspace-cookbooks/nodestack?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
This cookbook deploys a NodeJS applitcation stack.

Requirements
------------

#### cookbooks
- apt
- mysql
- mysql-multi
- database
- chef-sugar
- apt
- mysql-multi
- pg-multi
- database
- chef-sugar
- elasticsearch
- apache2, ~> 1.10
- memcached
- openssl
- redisio
- varnish
- rackspace_gluster
- platformstack
- mongodb
- build-essential
- java
- yum
- git
- nodejs
- ssh_known_hosts
- application
- magic_shell
- logrotate


Attributes
----------

####Note: the 'my_nodejs_app' defines the name of the app, please change this to something more relevant to the customer.

`node['nodestack']['apps']['my_nodejs_app']['app_dir']` path where the application will be deployed

`node['nodestack']['apps']['my_nodejs_app']['git_repo']` Git repository where the code lives.

`node['nodestack']['apps']['my_nodejs_app']['git_rev']` Code revision or branch that should be used ('origin/' should not be specified for remote branches.) Example: HEAD

`node['nodestack']['apps']['my_nodejs_app']['git_repo_domain']` The domain name for the git repo. Example: `github.com`

`node['nodestack']['apps']['my_nodejs_app']['entry_point']` the .js file that will be ran as the server.

`node['nodestack']['apps']['my_nodejs_app']['npm']` `true/false` - Wether we should run `npm install` during a deployment.

`node['nodestack']['apps']['my_nodejs_app']['npm_options']` `Array` - NPM command line options to use for the application.  '--production' should usually be included unless development is being done on the server.

`node['nodestack']['apps']['my_nodejs_app']['config_file']` `true/false` - Wether the coobook will write a config.js from the following config hash.

`node['nodestack']['apps']['my_nodejs_app']['env']`= {} - This config hash contains environment variables that will be available to the application.

`node['nodestack']['apps']['my_nodejs_app']['env']['PORT']` This is the only `env` attribute the cookbook expects to have by default, this is the port the app listens on.

`node['nodestack']['apps']['my_nodejs_app']['monitoring']['body']` Text that will be matched from the GET request

`node['nodestack']['apps']['my_nodejs_app']['deployment']['before_symlink']` Exposes the before_symlink attribute for the application resource. Set this to `nil` if you're not planning on using it.

`node['nodestack']['apps']['my_nodejs_app']['deployment']['before_symlink_template']` Template file that will be dropped on the revision folder that will be ran by the before_symlink callback. Set this to `nil` if you're not planning on using it.

`node['nodestack']['apps']['my_nodejs_app']['deployment']['template_options']` Hash of values that can be used in the `before_symlink_template`.

`node['nodestack']['apps']['my_nodejs_app']['deployment']['strategy']` This is the strategy that will be used to run the Node.js application. Currently Nodestack only supports `forever`. Scroll further down to the deployment strategy section to read more about this.

`node['nodestack']['apps']['my_nodejs_app']['open_files']` This sets the application user's file open limit (ulimit -n) - this is useful for upping the total number of concurrent websockets.

`node['nodestack']['forever']['watch_ignore_patterns'] = ['*.log', '*.logs']` This is a list of patterns that will be ignored and not watched by forever-monitor. Forever-monitor watches the code directory (in the demo app `/var/app/current`) and will reload the application if it notices any changes in the files.

`node['nodestack']['code_deployment']` This enables or disabled code deployment.

Deployment strategy
----

In the near future, nodestack may support more than one deployment strategy, for now it only supports forever.

### Forever

With this deployment strategy, we use whatever init system is running on the OS to start/stop a service that starts a very simple Node.js app that starts [forever-monitor](https://github.com/nodejitsu/forever-monitor).

This application will monitor and supervise the Node.js application the application being deployed. Forever-monitor will monitor any changes on the application files and reload itself if it finds any changes. It will also control the logging and the pids for the child process. There's also other options that can be implemented in the future, like the amount of child processes.

#### Code deployment is optional.

Nodestack can be deployed on a server without the deploying an application. Please note that the deployment strategy used will need to consider installing dependencies through NPM and starting/stopping the application. Some of these could be handled on a wrapper cookbook if so desired.

To make code deployment optional you need to set the following attribute `node['nodestack']['code_deployment'] = false`

## Encrypted Data Bags

This cookbook uses encrypted databags to fill in the config.js file for the application. This `config.js` file is where you would usually include credentials for third party services, API keys, database passwords, etc. The data bag also stores the deployment private key.
The top level key in the databag represents the environment.

Example of the contents of a databag:

```json
{
  "id": "config",
  "staging": {
    "ssh_deployment_key": "-----BEGIN RSA PRIVATE KEY-----\Ia+q5KO/FfGc2pD2bt2Vh9Tjg==\n-----END RSA PRIVATE KEY-----",
    "config": {
      "mysql": {
        "password": "randompass"
      },
      "mongo": {
        "host": "192.168.1.1",
        "port": 27027
      }
    }
  }
}
```

#### Attributes expected from an encrypted databag:

`config = {}` Configuration hash with all the information that the application needs

`ssh_deployment_key =''` SSH private key for deployment.

**It's important to name the databag with the `app_name` and then `_databag`**

Usage
-----
To deploy an app node these is how a `nodejs_app` role would look like:
```text
$ knife role show nodejs_app
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                nodejs_app
override_attributes:
run_list:
  recipe[platformstack::default]
  recipe[rackops_rolebook::default]
  recipe[nodestack::application_nodejs]
```

To deploy a standalone db for an app node these is how a `nodejs_mysql` role would look like:
```text
$ knife role show nodejs_mysql
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                nodejs_mysql
override_attributes:
run_list:
  recipe[platformstack::default]
  recipe[rackops_rolebook::default]
  recipe[nodestack::mysql_base]
```

To deploy a mongo node these is how a `nodejs_mongo` role would look like:
```text
$ knife role show nodejs_mongo
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                nodejs_mongo
override_attributes:
run_list:
  recipe[platformstack::default]
  recipe[rackops_rolebook::default]
  recipe[nodestack::mongodb_standalone]
```

These are the minimum environment variables that would be needed:
```text
$ knife environment show nodejs
chef_type:           environment
cookbook_versions:
default_attributes:
description:
json_class:          Chef::Environment
name:                nodejs
override_attributes:
  mysql:
    server_root_password: randompass
  mysql-multi:
    master: 10.x.x.x
  nodestack:
    app_name: beer_survey
    git_repo: https://github.com/jrperritt/beer-survey.git
  platformstack:
    cloud_backup:
      enabled: false
    cloud_monitoring:
      enabled: false
  rackspace:
    cloud_credentials:
      api_key:  xxx
      username: xxx
```

* Building MySQL cluster for nodestack.

Ensure the following attributes are set within environment or wrapper cookbook.

```
['mysql']['server_repl_password'] = 'rootlogin'
['mysql']['server_repl_password'] = 'replicantlogin'
['mysql-multi']['master'] = '1.2.3.4'
['mysql-multi']['slaves'] = ['5.6.7.8']
```

MySQL Master node:
```text
$ knife role show nodejs_mysql_master
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                nodejs_mysql_master
override_attributes:
run_list:
  recipe[platformstack::default]
  recipe[rackops_rolebook::default]
  recipe[nodestack::mysql_master]
```

MySQL Slave node:
```text
$ knife role show nodejs_mysql_slave
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                nodejs_mysql_slave
override_attributes:
run_list:
  recipe[platformstack::default]
  recipe[rackops_rolebook::default]
  recipe[nodestack::mysql_slave]
```

* Building a PostgreSQL cluster for nodestack.

Ensure the following attributes are set within environment or wrapper cookbook.

```
['postgresql']['version'] = '9.3'
['postgresql']['password'] = 'postgresdefault'
['pg-multi']['replication']['password'] = 'useagudpasswd'
['pg-multi']['master_ip'] = '1.2.3.4'
['pg-multi']['slave_ip'] = ['5.6.7.8']

Depending on OS one of the following two must be set:
['postgresql']['enable_pdgd_yum'] = true  (Redhat Family)
['postgresql']['enable_pdgd_apt'] = true  (Debian Family)
```

PostgreSQL Master node:
```text
$ knife role show nodejs_postgresql_master
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                nodejs_postgresql_master
override_attributes:
run_list:
  recipe[platformstack::default]
  recipe[rackops_rolebook::default]
  recipe[nodestack::postgresql_master]
```

PostgreSQL Slave node:
```text
$ knife role show nodejs_postgresql_slave
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                nodejs_postgresql_slave
override_attributes:
run_list:
  recipe[platformstack::default]
  recipe[rackops_rolebook::default]
  recipe[nodestack::postgresql_slave]
```

Cloud Monitoring
-----------

To enable monitoring you need to set `node['platformstack']['cloud_monitoring']['enabled'] = true`. This will setup the OS monitors like filesystem, CPU, memory, networking, etc.

To enable HTTP checks for a Node.js app deployed with Nodestack, set the `node['nodestack']['cloud_monitoring']['remote_http']['disabled'] = false`.

`default['nodestack']['cloud_monitoring']['remote_http']['disabled']` Enable/disable remote HTTP monitoring.
`default['nodestack']['cloud_monitoring']['remote_http']['alarm']` Enable/disable alarm notifications.
`default['nodestack']['cloud_monitoring']['remote_http']['period']` Seconds value on how often the check will be performed.
`default['nodestack']['cloud_monitoring']['remote_http']['timeout']` Seconds value on the timeout before the check fails.

New Relic Monitoring
--------------------

To configure New Relic, make sure the `node['newrelic']['license']`
attribute is set and include the `platformstack` cookbook in your run_list.

New Relic monitoring plugins can be configured by including the `newrelic::meetme-plugin`
recipe in your run_list and setting the following attribute hash in an application
cookbook:

```ruby
node.override['newrelic']['meetme-plugin']['services'] = {
  "memcached": {
    "name": "localhost",
    "host":  "host",
    "port":  11211
  },
  "elasticsearch": {
    "name": "clustername",
    "host": "localhost",
    "port": 9200
  }
}
```

More examples can be found [here](https://github.com/escapestudios-cookbooks/newrelic#meetme-pluginrb)
and [here](https://github.com/MeetMe/newrelic-plugin-agent#configuration-example).

Logrotate
---------
logrotate is now enabled, by default, for customer app(forever.[log|out|err]) log files.
The logrotate recipe iterates over every item(app_name) in the node['nodestack']['apps_to_deploy'] list
and creates a configuration file. i.e /etc/logrotate.d/my_nodejs_app

NOTE: The logrotate recipe does not rotate custom log files, so make sure the customer's app uses STDOUT and STDERR.

Configuration examples can be found [here](https://supermarket.getchef.com/cookbooks/logrotate)
and [here](https://github.com/stevendanna/logrotate)


Contributing
------------
* See the guide [here](https://github.com/rackspace-cookbooks/contributing/blob/master/CONTRIBUTING.md)

License and Authors
-------------------
- Author:: Rackspace DevOps (devops@rackspace.com)

```text
Copyright 2014, Rackspace, US Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
