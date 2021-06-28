require_relative '../spec_helper'

describe 'minitest-handler::default' do
  let(:chef_run) { ChefSpec::ServerRunner.new.converge(described_recipe) }

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
