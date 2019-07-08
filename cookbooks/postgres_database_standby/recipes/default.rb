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

cookbook_file '/etc/postgresql/10/main/pg_hba.conf' do
  source 'pg_hba.conf'
  action :create
end

cookbook_file '/etc/postgresql/10/main/postgresql.conf' do
  source 'postgresql.conf'
  action :create
end

service 'postgresql' do
  action :stop
end

execute 'Remove old data directory if it exists' do
  command 'rm -rf /var/lib/postgresql/10/main_old'
  action :run
end

execute 'Move data directory' do
  command 'mv /var/lib/postgresql/10/main /var/lib/postgresql/10/main_old'
  only_if 'ls /var/lib/postgresql/10/ | grep main'
end

execute 'Run backup utility' do
  command 'pg_basebackup -h 10.138.0.16 -D /var/lib/postgresql/10/main -U postgres -v --wal-method=stream'
  action :run
end

execute 'Set data directory owner' do
  command 'chown -R postgres /var/lib/postgresql/10/main'
  action :run
end

cookbook_file '/var/lib/postgresql/10/main/recovery.conf' do
  source 'recovery.conf'
  action :create
end

service 'postgresql' do
  action :start
end
