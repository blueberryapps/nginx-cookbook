#
# Cookbook:: nginx
# Attribute:: passenger
#
# Author:: Alex Dergachev (<alex@evolvingweb.ca>)
#
# Copyright:: 2013-2017, Chef Software, Inc.
# Copyright:: 2012-2017, Susan Potter
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
ubuntu_18 = platform?('ubuntu') && node['platform_version'].to_i >= 18
debian_9  = platform?('debian') && node['platform_version'].to_i >= 9

# this is only used for source installs
# for package installs you will receive the latest version in the repository
node.default['nginx']['passenger']['version'] = '4.0.57'

if node['nginx']['repo_source'] == 'passenger'
  node.default['nginx']['passenger']['root'] = '/usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini'
  node.default['nginx']['passenger']['ruby'] = '/usr/bin/ruby'
elsif node['languages'].attribute?('ruby')
  node.default['nginx']['passenger']['root'] = "#{node['languages']['ruby']['gems_dir']}/gems/passenger-#{node['nginx']['passenger']['version']}"
  node.default['nginx']['passenger']['ruby'] = node['languages']['ruby']['ruby_bin']
else
  Chef::Log.warn("node['languages']['ruby'] attribute not detected in #{cookbook_name}::#{recipe_name}")
  Chef::Log.warn("Install a Ruby for automatic detection of node['nginx']['passenger'] attributes (root, ruby)")
  Chef::Log.warn('Using default values that may or may not work for this system.')
  node.default['nginx']['passenger']['root'] = "/usr/lib/ruby/gems/1.8/gems/passenger-#{node['nginx']['passenger']['version']}"
  node.default['nginx']['passenger']['ruby'] = '/usr/bin/ruby'
end

node.default['nginx']['passenger']['conf_file'] = if debian_9 || ubuntu_18
                                                    "#{node['nginx']['dir']}/conf.d/mod-http-passenger.conf"
                                                  else
                                                    "#{node['nginx']['dir']}/conf.d/passenger.conf"
                                                  end

node.default['nginx']['passenger']['packages']['rhel'] = if platform_family?('rhel') && node['platform_version'].to_i >= 6
                                                           %w(ruby-devel libcurl-devel)
                                                         else
                                                           %w(ruby-devel curl-devel)
                                                         end
node.default['nginx']['passenger']['packages']['fedora'] = %w(ruby-devel libcurl-devel)
node.default['nginx']['passenger']['packages']['debian'] = if debian_9 || ubuntu_18
                                                             %w(ruby-dev libcurl4-gnutls-dev libnginx-mod-http-passenger)
                                                           else
                                                             %w(ruby-dev libcurl4-gnutls-dev)
                                                           end

node.default['nginx']['passenger']['install_rake'] = true
node.default['nginx']['passenger']['spawn_method'] = 'smart-lv2'
node.default['nginx']['passenger']['buffer_response'] = 'on'
node.default['nginx']['passenger']['max_pool_size'] = 6
node.default['nginx']['passenger']['min_instances'] = 1
node.default['nginx']['passenger']['max_instances_per_app'] = 0
node.default['nginx']['passenger']['pool_idle_time'] = 300
node.default['nginx']['passenger']['max_requests'] = 0
node.default['nginx']['passenger']['gem_binary'] = nil
node.default['nginx']['passenger']['show_version_in_header'] = 'on'
# By default, the Passenger log file is the global Nginx error log file. Set this attribute to write passenger log to another location.
node.default['nginx']['passenger']['passenger_log_file'] = nil

# NodeJs disable by default
node.default['nginx']['passenger']['nodejs'] = nil
