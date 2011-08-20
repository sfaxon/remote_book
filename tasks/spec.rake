ENV['BUNDLE_GEMFILE'] = File.dirname(__FILE__) + '/../Gemfile'

require 'rake'
require 'rake/testtask'
require 'rspec'
require 'rspec/core/rake_task'

desc "Run the test suite"
task :spec => ['spec:setup', 'spec:remote_book_lib', 'spec:cleanup']

namespace :spec do
  desc "Setup the test environment"
  task :setup do
  end
  
  desc "Cleanup the test environment"
  task :cleanup do
  end

  desc "Test the remote_book library"
  RSpec::Core::RakeTask.new(:remote_book_lib) do |task|
    remote_book_root = File.expand_path(File.dirname(__FILE__) + '/..')
    task.pattern = remote_book_root + '/spec/lib/**/*_spec.rb'
  end

  desc "Run the coverage report"
  RSpec::Core::RakeTask.new(:rcov) do |task|
    remote_book_root = File.expand_path(File.dirname(__FILE__) + '/..')
    task.pattern = remote_book_root + '/spec/lib/**/*_spec.rb'
    task.rcov=true
    task.rcov_opts = %w{--rails --exclude osx\/objc,gems\/,spec\/,features\/}
  end
end
