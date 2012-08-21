Cookbook: minitest-handler  
Author: Bryan McLellan <btm@loftninjas.org>  
Author: Bryan W. Berry <bryan.berry@gmail.com>  
Author: David Petzel <davidpetzel@gmail.com>
Copyright: 2012 Opscode, Inc.  
License: Apache 2.0  

Description
===========

# <a name="title"></a> minitest-handler [![Build Status](https://secure.travis-ci.org/btm/minitest-handler-cookbook.png?branch=master)](http://travis-ci.org/btm/minitest-handler-cookbook)

This cookbook utilizes the minitest-chef-handler project to facilitate cookbook testing.

minitest-chef-handler project: https://github.com/calavera/minitest-chef-handler  
stable minitest-handler cookbook: http://community.opscode.com/cookbooks/minitest-handler  
minitest-handler cookbook development: https://github.com/btm/minitest-handler-cookbook  

*Note*: Version 0.1.0 added a change that breaks backward compatibility. The minitest-handler now only loads 
test files named "recipe-name_test.rb" rather than all test files in the path files/default/tests/minitest/*_test.rb

If you have any helper libraries, place them in files/default/tests/minitest/support/

Attributes
==========

* node[:minitest][:path] - Location to store and find tests, defaults to `/var/chef/minitest`
* node[:minitest][:tests] - Test files to run, defaults to `**/*_test.rb`

Usage
=====

* The node run list should begin with 'recipe[minitest-handler]'
* Each cookbook should contain tests in the 'files/default/tests/minitest' directory with a file with the name of 'your-recipe-name_test.rb' if you are testing the default recipe, the file should be named 'default_test.rb'

Minitest: https://github.com/seattlerb/minitest

Examples
========

### Traditional minitest

    class TestApache2 < MiniTest::Chef::TestCase
      def test_that_the_package_installed
        case node[:platform]
        when "ubuntu","debian"
          assert system('apt-cache policy apache2 | grep Installed | grep -v none')
        end
      end
    
      def test_that_the_service_is_running
        assert system('/etc/init.d/apache2 status')
      end
    
      def test_that_the_service_is_enabled
        assert File.exists?(Dir.glob("/etc/rc5.d/S*apache2").first)
      end
    end


### Using minitest/spec

    require 'minitest/spec'

    describe_recipe 'ark::test' do

      # It's often convenient to load these includes in a separate
      # helper along with
      # your own helper methods, but here we just include them directly:
      include MiniTest::Chef::Assertions
      include MiniTest::Chef::Context
      include MiniTest::Chef::Resources

      it "installed the unzip package" do
        package("unzip").must_be_installed
      end

      it "dumps the correct files into place with correct owner and group" do
        file("/usr/local/foo_dump/foo1.txt").must_have(:owner, "foobarbaz").and(:group, "foobarbaz")
      end

     end

For more detailed examples, see [here](https://github.com/calavera/minitest-chef-handler/blob/v0.4.0/examples/spec_examples/files/default/tests/minitest/example_test.rb)
