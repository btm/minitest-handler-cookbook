require 'chefspec'
require 'chefspec/berkshelf'

# Require all our libraries
Dir['libraries/*.rb'].each { |f| require File.expand_path(f) }

RSpec.configure do |config|
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

at_exit { ChefSpec::Coverage.report! }
