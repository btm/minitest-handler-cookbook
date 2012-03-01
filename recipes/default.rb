# Hack to install Gem immediately pre Chef 0.10.10 (CHEF-2879)
r = gem_package "minitest" do
  action :nothing
end

r.run_action(:install)
Gem.clear_paths

# Download latest copy of minitest-chef-handler
remote_file "minitest-chef-handler" do
  source "https://raw.github.com/calavera/minitest-chef-handler/master/lib/minitest-chef-handler.rb"
  path "#{node["chef_handler"]["handler_path"]}/minitest-chef-handler.rb"
end

# Directory to store cookbook tests
directory node[:minitest][:path] do
  owner "root"
  group "root"
end

# Search through all cookbooks in the run list for tests
node[:recipes].each do |recipe|
  # recipes is actually a list of cookbooks and recipes with :: as a delimiter
  cookbook_name = recipe.split('::').first
  remote_directory "tests-#{cookbook_name}" do
    source "tests/minitest"
    cookbook cookbook_name
    path "#{node[:minitest][:path]}/#{cookbook_name}"
    purge true
    ignore_failure true
  end
end

# Install the handler using the LWRP in the chef_handler cookbook
chef_handler "MiniTest::Chef::Handler" do
  source "#{node["chef_handler"]["handler_path"]}/minitest-chef-handler.rb"
  arguments :verbose => true, :path => "#{node[:minitest][:path]}/**/*_test.rb"
  action :enable
end

