# Hack to install Gem immediately pre Chef 0.10.10 (CHEF-2879)
gem_package "minitest" do
  action :nothing
end.run_action(:install)

gem_package "minitest-chef-handler" do
  action :nothing
end.run_action(:install)

Gem.clear_paths
require "minitest-chef-handler"

# Directory to store cookbook tests
directory "minitest test location" do
  path node[:minitest][:path]
  owner "root"
  group "root"
end

ruby_block "delete tests from old cookbooks" do
  block do
    raise "minitest-handler cookbook could not find directory '#{node[:minitest][:path]}'" unless File.directory?(node[:minitest][:path])
    expired_cookbooks = Dir.entries(node[:minitest][:path]).delete_if { |dir| dir == '.' || dir == '..' || node[:recipes].include?(dir) }
    expired_cookbooks.each do |cookbook|
      Chef::Log.info("Cookbook #{cookbook} no longer in run list, remove minitest tests")
      FileUtils.rm_rf "#{node[:minitest][:path]}/#{cookbook}"
    end
  end
end

# Search through all cookbooks in the run list for tests
node[:recipes].each do |recipe|
  # recipes is actually a list of cookbooks and recipes with :: as a delimiter
  cookbook_name, recipe_name = recipe.split('::')
  recipe_name = "default" if recipe_name.nil?
  remote_directory "tests-#{cookbook_name}" do
    source "tests/minitest/#{recipe_name}"
    cookbook cookbook_name
    path "#{node[:minitest][:path]}/#{cookbook_name}"
    purge true
    ignore_failure true
  end
end

ruby_block "remove tests no longer used" do
  block do
    require 'set'
    require 'fileutils'
    Chef::Log.debug("before getting current_test_dirs")
    current_test_dirs = node[:recipes].map do |recipe|
      cookbook_name, recipe_name = recipe.split('::')
      "#{node[:minitest][:path]}/#{cookbook_name}}"      
    end
    Chef::Log.debug("current_test_dirs are #{current_test_dirs}")
    current_test_dirs_set = Set.new current_test_dirs
    all_test_dirs = ::Dir["#{node[:minitest][:path]}/**/*"].select { |entry| File.directory? entry }
    all_test_dirs_set = Set.new all_test_dirs
    unused_test_dirs_set = all_test_dirs_set.difference current_test_dirs_set
    unused_test_dirs_set.delete "#{node[:minitest][:path]}/chef_handler-default"
    unused_test_dirs_set.delete "#{node[:minitest][:path]}/minitest-handler-recipes"
    unless unused_test_dirs_set.empty?
      Chef::Log.debug("Dirs to remove #{unused_test_dirs_set.entries}")
      FileUtils.rm_rf unused_test_dirs_set.entries
    end
  end
end


handler = MiniTest::Chef::Handler.new({
  :path    => "#{node[:minitest][:path]}/**/*_test.rb",
  :verbose => true})

Chef::Log.info("Enabling minitest-chef-handler as a report handler")
Chef::Config.send("report_handlers").delete_if {|v| v.class.to_s.include? MiniTest::Chef::Handler}
Chef::Config.send("report_handlers") << handler

