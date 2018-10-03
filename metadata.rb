name 'minitest-handler'
maintainer 'David Petzel'
maintainer_email 'davidpetzel@gmail.com'
source_url 'https://github.com/btm/minitest-handler-cookbook' if respond_to?(:source_url)
issues_url 'https://github.com/btm/minitest-handler-cookbook/issues' if respond_to?(:issues_url)
license 'Apache-2.0'
description 'Installs and configures minitest-chef-handler'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.5.1'

%w(ubuntu centos).each do |os|
  supports os
end
chef_version '>= 10.0' if respond_to?(:chef_version)

depends 'chef_handler'
