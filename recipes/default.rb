::Chef::Resource::RubyBlock.send(:include, MinitestHandler::CookbookHelper)

[:delete, :create].each do |action|
  directory "#{action} minitest test location" do
    path node['minitest']['path']
    owner node['minitest']['owner']
    group node['minitest']['group']
    mode node['minitest']['mode']
    recursive true
    action action
  end
end

# Search through all cookbooks in the run list for tests
ruby_block 'load_tests_and_register_handler' do
  block do
    load_tests
    register_handler
  end
end

Chef.event_handler do
  on :converge_start do
    MinitestHandler::RSpecHack.fix_describe
  end
end
