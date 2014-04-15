# Create one recipe-name_test.rb file for each recipe to be tested.
require File.expand_path('helpers', File.dirname(__FILE__))

# For your own cookbooks, describe mycookbookname::default
describe 'minitest-handler::not_default' do

  # Helpers::MinitestHandler library is defined at
  # #{cookbook_root}/files/default/tests/minitest/support/helpers.rb
  # For each cookbook, rename library to Helpers::MyCookbookName
  # in this file and in helpers.rb
  include Helpers::MinitestHandler

  # For test examples, see: http://bit.ly/1sJO1oC
  it 'runs no tests' do
  end

end
