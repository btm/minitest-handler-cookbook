include_recipe "chef_handler"
recipes = []

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

# delete dir holding tests, then recreate it
[:delete, :create].each do |action|
  directory "minitest test location" do
    path node['minitest']['path']
    owner node['minitest']['owner']
    group node['minitest']['group']
    mode 00755
    recursive true
    action action
  end
end

# Search through all cookbooks in the run list for tests
ruby_block "load tests" do
  block do
    recipes = []

    if Chef::VERSION < "11.0"
      seen_recipes = node.run_state[:seen_recipes]
      recipes = seen_recipes.keys.each { |i| i }
    else
      recipes = run_context.loaded_recipes
    end
    if recipes.empty? and Chef::Config[:solo]
      #If you have roles listed in your run list they are NOT expanded
      recipes = node.run_list.map {|item| item.name if item.type == :recipe }
    end
    
    recipes.each do |recipe|
      # recipes is actually a list of cookbooks and recipes with :: as a
      # delimiter
      cookbook_name,recipe_name = recipe.split('::')
      recipe_name ||= "default"
      
      if recipes.any? { |recipe| recipe.split('::').first == cookbook_name }
        # create the parent directory
        dir = Chef::Resource::Directory.new("#{node['minitest']['path']}/#{cookbook_name}", run_context)
        dir.recursive(true)
        dir.run_action :create

        ckbk = run_context.cookbook_collection[cookbook_name]
        begin
          ckbk.preferred_manifest_record(node, 'files', "tests/minitest/#{recipe_name}_test.rb")
          ckbk_f = Chef::Resource::CookbookFile.new("tests-#{cookbook_name}-#{recipe_name}", run_context)
          ckbk_f.source "tests/minitest/#{recipe_name}_test.rb"
          ckbk_f.cookbook cookbook_name
          ckbk_f.path "#{node['minitest']['path']}/#{cookbook_name}/#{recipe_name}_test.rb"
          ckbk_f.ignore_failure true
          ckbk_f.run_action :create
        rescue Chef::Exceptions::FileNotFound
        end

        begin
          # This will raise at compile-time if we can't find the directory
          ckbk.preferred_manifest_records_for_directory(node, 'files', 'tests/minitest/support')

          # copy any helper files from the support directory
          ckbk_d = Chef::Resource::RemoteDirectory.new("tests-support-#{cookbook_name}-#{recipe_name}", run_context)
          ckbk_d.source "tests/minitest/support"
          ckbk_d.cookbook cookbook_name
          ckbk_d.path "#{node['minitest']['path']}/#{cookbook_name}/support"
          ckbk_d.recursive true
          ckbk_d.ignore_failure true
          ckbk_d.run_action :create
        rescue Chef::Exceptions::FileNotFound
        end
      end
    end

    options = {
      :path    => "#{node['minitest']['path']}/#{node['minitest']['tests']}",
      :verbose => node['minitest']['verbose']}
    # The following options are optional
    options[:filter]     = node['minitest']['filter'] if node['minitest'].include? 'filter'
    options[:seed]       = node['minitest']['seed'] if node['minitest'].include? 'seed'
    options[:ci_reports] = node['minitest']['ci_reports'] if node['minitest'].include? 'ci_reports'

    handler = MiniTest::Chef::Handler.new(options)

    Chef::Log.info("Enabling minitest-chef-handler as a report handler")
    Chef::Config.send("report_handlers").delete_if {|v| v.class.to_s.include? MiniTest::Chef::Handler.to_s}
    Chef::Config.send("report_handlers") << handler
  end
end
