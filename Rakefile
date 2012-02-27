raise "jruby-jms must be built with JRuby: try again with `jruby -S rake'" unless defined?(JRUBY_VERSION)

require 'rake/clean'
require 'rake/testtask'
require 'date'
require 'java'

desc "Build gem"
task :gem  do |t|
  system 'gem build jruby-jms.gemspec'
end

task :test do

  Rake::TestTask.new(:functional) do |t|
    t.test_files = FileList['test/*_test.rb']
    t.verbose    = true
  end

  Rake::Task['functional'].invoke
end

desc "Generate RDOC documentation"
task :doc do
  system "rdoc --main README.md --inline-source --quiet README.md `find lib -name '*.rb'`"
end

