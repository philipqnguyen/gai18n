require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rspec/core/rake_task'

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--pattern spec/**/*_spec.rb'
end

task default: %i[spec]
