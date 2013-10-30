
module MinitestHandler
  module CookbookHelper
    
    # Load necessary tests onto the filesystem
    def load_tests(scratch_dir)
      require 'fileutils'
      
      unless node[:minitest][:recipes].empty?
        recipes = node[:minitest][:recipes].dup
      else
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
      end
  
      recipes.each do |recipe|
        # recipes is actually a list of cookbooks and recipes with :: as a
        # delimiter
        unless recipe.include?("::")
          cookbook_name = recipe
          recipe_name = "default"
        else
          cookbook_name,recipe_name = recipe.split('::')
        end
  
        # create the parent directory
        dir = Chef::Resource::Directory.new("#{node[:minitest][:path]}/#{cookbook_name}", run_context)
        dir.recursive(true)
        dir.run_action :create
        
        # https://github.com/btm/minitest-handler-cookbook/issues/42
        # Ensure we download cookbooks from Chef Server so the rest
        # of this code works. It would appear that if the file is not
        # in the resource list, its never downloaded, so we have to
        # 'force' a download. **NOTE** We force the download to a
        # directory we don't use. This looks odd, but actually has a purpose
        # We don't want to download them directly into the minitest dir
        # as that results in tests running for recipes not in the runlist
        # and the provider is going to copy them into the cookbook cache
        # automatically, just essentially set the path to a bogus location
        unless Chef::Config[:solo]
          ckbk = run_context.cookbook_collection[cookbook_name]
          # Support both old and new locations
          old_path = "tests/minitest"
          new_path = "test"
          
          [old_path, new_path].each do |test_path|
            begin
              # This will raise at compile-time if we can't find the directory
              ckbk.preferred_manifest_records_for_directory(node, 'files', test_path)
  
              # copy the test files
              ckbk_d = Chef::Resource::RemoteDirectory.new("tests-support-#{cookbook_name}-#{recipe_name}", run_context)
              ckbk_d.source test_path
              ckbk_d.cookbook cookbook_name
              ckbk_d.path ::File.join(scratch_dir, cookbook_name)
              ckbk_d.recursive true
              ckbk_d.ignore_failure true
              ckbk_d.run_action :create
            rescue Chef::Exceptions::FileNotFound
              Chef::Log.debug "No test file directory found at #{test_path}."
            end
          end
        end
        
        tests = Array(Chef::Config[:cookbook_path]).map do |cookbook_path|
          ::Dir["#{cookbook_path}/#{cookbook_name}/files/default/**/#{recipe_name}_test.rb"]
        end.flatten(1)
        unless tests.empty?
          FileUtils.cp tests, "#{node[:minitest][:path]}/#{cookbook_name}/"
        end
  
        support_files = Array(Chef::Config[:cookbook_path]).map do |cookbook_path|
          ::Dir["#{cookbook_path}/#{cookbook_name}/files/default/**/*helper*.rb"]
        end.flatten(1)
        
        unless support_files.empty?
          # do this in a loop to preserve directory structure
          # for backwards compatibility for dumb idea of putting support files in support/
          support_files.each do |f|
            if f =~ /tests\/minitest\/support/
              dest_dir = "#{node[:minitest][:path]}/#{cookbook_name}/support/"
              begin
                FileUtils.mkdir dest_dir
              rescue Errno::EEXIST
              end
            else
              dest_dir = "#{node[:minitest][:path]}/#{cookbook_name}/"
            end
            FileUtils.cp support_files, dest_dir
          end
        end
      end
  
      options = {
        :path => "#{node[:minitest][:path]}/#{node[:minitest][:tests]}",
        :verbose => node[:minitest][:verbose]}
      # The following options can be omited
      options[:filter]     = node[:minitest][:filter] if node[:minitest].include? 'filter'
      options[:seed]       = node[:minitest][:seed] if node[:minitest].include? 'seed'
      options[:ci_reports] = node[:minitest][:ci_reports] if node[:minitest].include? 'ci_reports'
  
      handler = MiniTest::Chef::Handler.new(options)
  
      Chef::Log.info("Enabling minitest-chef-handler as a report handler")
      Chef::Config.send("report_handlers").delete_if {|v| v.class.to_s.include? MiniTest::Chef::Handler.to_s}
      Chef::Config.send("report_handlers") << handler
    end
  end
end
