default[:minitest][:tests] = '**/*_test.rb'
default[:minitest][:recipes] = []
default[:minitest][:ignore_recipes] = []
default[:minitest][:verbose] = true
default[:minitest][:path] = '/var/chef/minitest'

case node['os']
when 'windows'
  # Usin nil to prevent this from being applied on Windows
  default[:minitest][:owner] = nil
  default[:minitest][:group] = nil
  default[:minitest][:mode] = nil
else
  # Default values for Linux
  default[:minitest][:owner] = 'root'
  default[:minitest][:group] = 'root'
  default[:minitest][:mode] = '0775'
end
