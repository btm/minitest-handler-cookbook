# This test file is used to validate that tests for recipes
# not in the run_list do not show up
require File.expand_path('helpers', File.dirname(__FILE__))

describe 'minitest-handler::not_run' do
  include Helpers::MinitestHandler

  # For test examples, see: http://bit.ly/1sJO1oC
  it 'runs no tests' do
  end

end
