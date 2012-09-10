# Hack to install Gem immediately pre Chef 0.10.10 (CHEF-2879)
chef_gem "minitest" do
  version node['minitest']['gem_version']
  action :nothing
end.run_action(:install)

chef_gem "minitest-chef-handler" do
  action :nothing
end.run_action(:install)

Gem.clear_paths
# Ensure minitest gem is utilized
require "minitest-chef-handler"

recipes = node['recipes']
if recipes.empty? and Chef::Config[:solo]
  #If you have roles listed in your run list they are NOT expanded
  recipes = node.run_list.map {|item| item.name if item.type == :recipe }
end

# Directory to store cookbook tests
directory "minitest test location" do
  path node['minitest']['path']
  owner node['minitest']['owner']
  group node['minitest']['group']
  mode node['minitest']['mode']
  recursive true
end

ruby_block "delete tests from old cookbooks" do
  block do
    raise "minitest-handler cookbook could not find directory '#{node['minitest']['path']}'" unless File.directory?(node['minitest']['path'])
    expired_cookbooks = Dir.entries(node['minitest']['path']).delete_if { |dir| dir == '.' || dir == '..' || recipes.include?(dir) }
    expired_cookbooks.each do |cookbook|
      Chef::Log.info("Cookbook #{cookbook} no longer in run list, remove minitest tests")
      FileUtils.rm_rf "#{node['minitest']['path']}/#{cookbook}"
    end
  end
end

# Search through all cookbooks in the run list for tests
recipes.each do |recipe|
  # recipes is actually a list of cookbooks and recipes with :: as a
  # delimiter
  cookbook_name,recipe_name = recipe.split('::')
  recipe_name ||= "default"

  if node['recipes'].any? { |recipe| recipe.split('::').first == cookbook_name }
    # create the parent directory
    directory "#{node['minitest']['path']}/#{cookbook_name}" do
      recursive true
    end
    cookbook_file "tests-#{cookbook_name}-#{recipe_name}" do
      source "tests/minitest/#{recipe_name}_test.rb"
      cookbook cookbook_name
      path "#{node['minitest']['path']}/#{cookbook_name}/#{recipe_name}_test.rb"
      ignore_failure true
    end
    # copy any helper files from the support directory
    remote_directory "tests-support-#{cookbook_name}-#{recipe_name}" do
      source "tests/minitest/support"
      cookbook cookbook_name
      path "#{node['minitest']['path']}/#{cookbook_name}/support"
      recursive true
      ignore_failure true
    end
  end
end

handler = MiniTest::Chef::Handler.new({
  :path    => "#{node['minitest']['path']}/#{node['minitest']['tests']}",
  :verbose => true})

Chef::Log.info("Enabling minitest-chef-handler as a report handler")
Chef::Config.send("report_handlers").delete_if {|v| v.class.to_s.include? MiniTest::Chef::Handler.to_s}
Chef::Config.send("report_handlers") << handler

