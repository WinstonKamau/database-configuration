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

cookbook_file '/etc/postgresql/10/main/postgresql.conf' do
  source 'postgresql.conf'
  action :create
end

cookbook_file '/etc/postgresql/10/main/pg_hba.conf' do
  source 'pg_hba.conf'
  action :create
end

service 'postgresql' do
  action :restart
end

execute 'create-database' do
  command 'createdb -U postgres test-database'
  only_if "psql -U postgres -c \"SELECT COUNT(*) FROM pg_database WHERE datname = 'test-database';\" | grep 0"
end

execute 'create a table' do
  command "psql -U postgres -d test-database -c 'CREATE TABLE guestbook (visitor_email text, vistor_id serial, date timestamp, message text);'"
  only_if "psql -U postgres -d test-database -c \"SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'guestbook';\" | grep 0"
end

execute 'add entry to table' do
  command "psql -U postgres -d test-database -c \"INSERT INTO guestbook (visitor_email, date, message) VALUES ( 'jim@gmail.com', current_date, 'This is a test.');\""
end
