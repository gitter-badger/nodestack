# Encoding: utf-8
#
# Cookbook Name:: nodestack
# Recipe:: _user
#
# Copyright 2014, Rackspace Hosting
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This recipe creates the user that the application will run as, as well as setting up all the directories
# that we must ensure are created under the user and with the correct permissions

node['nodestack']['apps'].each do |app| # each app loop

  app_name = app[0]
  app_config = node['nodestack']['apps'][app_name]

  # Setup User
  user app_name do
    supports manage_home: true
    shell '/bin/bash'
    home "/home/#{app_name}"
  end

  # Makes sure the user can restart the application it will run.
  sudo app_name do
    user app_name
    nopasswd true
    commands ["/sbin/restart #{app_name}", "/sbin/start #{app_name}", "/sbin/stop #{app_name}"]
  end

  # Makes sures .npm folder has the right permissions.
  directory "/home/#{app_name}/.npm" do
    owner app_name
    group app_name
    mode 0755
    action :create
  end

  # Create directory for the following resource.
  directory "/home/#{app_name}/.ssh" do
    owner app_name
    group app_name
    mode 0700
    action :create
  end

  # Disable strict host checking for the git repo.
  template 'ssh config with strict host check disabled' do
    source 'ssh_config.erb'
    path "/home/#{app_name}/.ssh/config"
    mode 0700
    owner app_name
    group app_name
    variables(
      git_repo_domain: app_config['git_repo_domain']
    )
  end
end
