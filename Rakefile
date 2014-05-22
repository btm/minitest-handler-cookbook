#!/usr/bin/env rake
require 'foodcritic'
require 'rubocop'
require 'rspec/core'

task :default => 'test'

@cookbook = 'minitest-handler-cookbook'

desc 'Run tests'
task :test do
  Rake::Task[:foodcritic].execute
  Rake::Task[:rubocop].execute
  Rake::Task[:rspec].execute
end

desc 'Runs foodcritic linter'
task :foodcritic do
  if Gem::Version.new('1.9.2') <= Gem::Version.new(RUBY_VERSION.dup)

    puts 'Running foodcritic checks'
    review = ::FoodCritic::Linter.new.check(
      cookbook_paths: ['./'],
      search_gems: true
    )
    if review.warnings.any?
      puts review
      exit !review.failed?
    else
      puts 'No foodcritic issues'
    end
  else
    puts "WARN: foodcritic run is skipped as Ruby #{RUBY_VERSION} is < 1.9.2."
  end
end

desc 'Run Rubocop'
task :rubocop do
  puts 'Running Rubocop Style Checks'
  result = Rubocop::CLI.new.run([])
  if result == 0
    puts 'No Rubocop errors'
  else
    exit result
  end
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
