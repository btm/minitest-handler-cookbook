#!/usr/bin/env bats

@test "copies tests from cookbook matching filter" {
  [ -f "/var/chef/minitest/minitest-handler_test1/default_test.rb" ]
  [ -f "/var/chef/minitest/minitest-handler_test1/helpers.rb" ]
}

@test "it does not copy tests from cookbook not matching filter" {
  [ ! -f "/var/chef/minitest/minitest-handler_test2/include_recipe_test.rb" ]
  [ ! -f "/var/chef/minitest/minitest-handler_test2/legacy_paths_test.rb" ]
  [ ! -d "/var/chef/minitest/minitest-handler_test2" ]
}
