#!/usr/bin/env rake
require 'cookstyle'
require 'rubocop/rake_task'
require 'rspec/core'

task :default => 'test'

@cookbook = 'minitest-handler-cookbook'

desc 'Run tests'
task :test do
  Rake::Task[:rubocop].execute
  Rake::Task[:rspec].execute
end

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options << '--display-cop-names'
end

desc 'Perform rspec tests'
task :rspec do
  puts 'Running rspec tests'
  spec_runner = RSpec::Core::Runner.run(FileList['spec/**/*_spec.rb'])
  if spec_runner > 0
    puts 'Spec failures detected'
    exit spec_runner
  else
    puts 'All spec tests passed'
  end
end

require 'kitchen'
desc 'Run Test Kitchen integration tests'
task :integration do
  Kitchen.logger = Kitchen.default_file_logger
  Kitchen::Config.new.instances.each do |instance|
    instance.test(:always)
  end
end
