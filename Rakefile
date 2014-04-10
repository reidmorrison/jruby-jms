lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

raise "jruby-jms must be built with JRuby: try again with `jruby -S rake'" unless defined?(JRUBY_VERSION)

require 'rubygems'
require 'rubygems/package'
require 'rake/clean'
require 'rake/testtask'
require 'jms/version'

desc "Build gem"
task :gem  do |t|
  Gem::Package.build(Gem::Specification.load('jruby-jms.gemspec'))
end

desc "Run Test Suite"
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
