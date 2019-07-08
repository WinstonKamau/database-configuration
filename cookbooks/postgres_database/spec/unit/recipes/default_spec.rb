#
# Cookbook:: postgres_database
# Spec:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'postgres_database::default' do
  context 'When all attributes are default, on Ubuntu 16.04' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04')
      runner.converge(described_recipe)
    end

    before do
      stub_command("psql -U postgres -c \"SELECT COUNT(*) FROM pg_database WHERE datname = 'test-database';\" | grep 0").and_return(false)
      stub_command("psql -U postgres -d test-database -c \"SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'guestbook';\" | grep 0").and_return(false)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end

  context 'When all attributes are default, on CentOS 7.4.1708' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '7.4.1708')
      runner.converge(described_recipe)
    end

    before do
      stub_command("psql -U postgres -c \"SELECT COUNT(*) FROM pg_database WHERE datname = 'test-database';\" | grep 0").and_return(false)
      stub_command("psql -U postgres -d test-database -c \"SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'guestbook';\" | grep 0").and_return(false)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
