class Chef::Resource::RubyBlock
  include MinitestHandler::CookbookHelper
end

# Hack to install Gem immediately pre Chef 0.10.10 (CHEF-2879)
chef_gem "minitest" do
  version node[:minitest][:gem_version]
  action :nothing
  only_if { Chef::VERSION.to_f < 10.10 }
end.run_action(:install)


chef_gem "minitest-chef-handler" do
  version node[:minitest][:chef_handler_gem_version]
  action :nothing
end.run_action(:install)

Gem.clear_paths
# Ensure minitest gem is utilized
require "minitest-chef-handler"

scratch_dir = ::File.join(Chef::Config[:file_cache_path], "minitest_scratch")

[:delete, :create].each do |action|
  directory "minitest test location" do
    path node[:minitest][:path]
    owner node[:minitest][:owner]
    group node[:minitest][:group]
    mode node[:minitest][:mode]
    recursive true
    action action
  end
  
  directory scratch_dir do
    path scratch_dir
    owner node[:minitest][:owner]
    group node[:minitest][:group]
    mode node[:minitest][:mode]
    recursive true
    action action
  end
end

# Search through all cookbooks in the run list for tests
ruby_block "load tests" do
  block do
    # Leverage the library code to load the test files
    load_tests()
  end
end
