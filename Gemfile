source 'https://rubygems.org'

gem 'berkshelf', '~> 5.6'
gem 'chefspec', '~> 6.2'
gem 'rubocop', '= 0.34.2'
gem 'foodcritic', '~> 10.3'
gem 'stove'

group :kitchen do
  gem 'test-kitchen', '~> 1.4', '>= 1.4.2'
  gem 'kitchen-vagrant', '~> 0.19.0'
  gem 'kitchen-digitalocean', '~> 0.9.3'
  gem 'kitchen-docker', '~> 2.3'
  gem 'kitchen-openstack', '~> 2.1'
  gem 'winrm-transport', '~> 1.0', '>= 1.0.2'
end

group :integration do
  gem 'rake'
  gem 'minitest', '~> 4.7.0', '>= 4.7.5'
  gem 'busser-bats'
  gem 'minitest-chef-handler', '~> 1.0.0', '>= 1.0.3'
end
