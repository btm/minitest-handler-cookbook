require 'chefspec'

describe 'minitest-handler::default' do

  it "should create the minitest directory at /var/foobar/minitest" do
    
    #Chef::Cookbook::CookbookCompiler.any_instance.stub(:files_in_cookbook_by_segment).with("chef_handler", segment).and_return(true)
    #files_in_cookbook_by_segment(cookbook_name, :libraries)
    chef_run = ChefSpec::ChefRunner.new(:log_level => :debug) do |node|
      node.set[:minitest][:path] = '/var/foobar/minitest'
    end
    chef_run.converge 'minitest-handler::default'
    chef_run.should create_directory '/var/foobar/minitest'
  end

end
