# Create one recipename_test.rb file for each recipe to be tested.
require File.expand_path('../support/helpers', __FILE__)

# For your own cookbooks, describe mycookbookname::default
describe 'minitesthandler::default' do

  # Helpers::MinitestHandler library is defined at #{cookbook_root}/files/default/tests/minitest/support/helpers.rb
  # For each cookbook, rename library to Helpers::MyCookbookName in this file and in helpers.rb
  include Helpers::MinitestHandler

  # For test examples, see:
  # https://github.com/calavera/minitest-chef-handler/blob/master/examples/spec_examples/files/default/tests/minitest/example_test.rb  
  it 'runs no tests' do
  end

end
