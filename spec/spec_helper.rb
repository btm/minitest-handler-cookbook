require 'thor'
require 'chefspec'
require 'chefspec/berkshelf'

# Require all our libraries
Dir['libraries/*.rb'].each { |f| require File.expand_path(f) }

RSpec.configure do |config|
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  # Specify platform and version for ChefSpec
  config.platform = 'ubuntu'
  config.version = '20.04'
end
