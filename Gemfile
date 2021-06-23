source 'https://rubygems.org'

gem 'berkshelf', '~> 7.2'
gem 'chefspec', '~> 9.3'
gem 'rubocop', '~> 1.15'
gem 'cookstyle', '~> 7.13'
gem 'stove'

group :kitchen do
  gem 'test-kitchen', '~> 2.12'
  gem 'kitchen-vagrant', '~> 1.8'
  gem 'kitchen-digitalocean', '~> 0.12.0'
  gem 'kitchen-docker', '~> 2.10'
  gem 'kitchen-openstack', '~> 6.0'
end

group :integration do
  gem 'rake'
  gem 'minitest', '~> 4.7.0', '>= 4.7.5'
  gem 'busser-bats'
  gem 'minitest-chef-handler', '~> 1.1'
end
