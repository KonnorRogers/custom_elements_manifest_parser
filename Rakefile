# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

require 'yard'

YARD::Rake::YardocTask.new do |t|
 t.files   = [
    'lib/**/*.rb',
    # OTHER_PATHS
  ]
 # t.options = ['--any', '--extra', '--opts'] # optional
 # t.stats_options = ['--list-undoc']         # optional
end

task default: :test

require 'yard-junk/rake'
# rake yard:junk
YardJunk::Rake.define_task
