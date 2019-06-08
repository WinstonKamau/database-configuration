#
# Cookbook:: postgres_database
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

# Set up the apt_update command to be running updates when the chef client run is called
# First step to setting up postgres is updating the apt cache

apt_update 'Update the apt cache on chef client runs' do
  action :update
end

package 'wget'
package 'ca-certificates'

execute 'Import the repository signing key' do
  command 'wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -'
  action :run
end

file '/etc/apt/sources.list.d/pgdg.list' do
  content 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main'
end

apt_update 'Update the package lists' do
  action :update
end

# Install core database server postgresql version 10
package 'postgresql-10'
# Install client libraries and binaries for postgresql version 10
package 'postgresql-client-10'