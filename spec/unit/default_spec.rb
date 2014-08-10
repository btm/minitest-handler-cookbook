require_relative '../spec_helper'

describe 'minitest-handler::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'installs minitest gem' do
    expect(chef_run).to install_chef_gem('minitest-chef-handler').at_compile_time
  end

  it 'installs ci_reporter gem' do
    expect(chef_run).to install_chef_gem('ci_reporter').at_compile_time
  end

  it 'installs minitest gem only before Chef 10.10' do
    if  Chef::VERSION.to_f < 10.10
      expect(chef_run).to install_chef_gem('minitest').at_compile_time
    else
      expect(chef_run).to_not install_chef_gem('minitest')
    end
  end

  it 'deletes old test file directories' do
    expect(chef_run).to delete_directory(
      'delete minitest test location').with(path: '/var/chef/minitest')
  end

  it 'creates base test directory directory' do
    expect(chef_run).to create_directory(
      'create minitest test location').with(path: '/var/chef/minitest')
  end

  it 'runs the test_loader' do
    expect(chef_run).to run_ruby_block('load_tests_and_register_handler')
  end

end
