raise "jruby-jms must be built with JRuby: try again with `jruby -S rake'" unless defined?(JRUBY_VERSION)

require 'rake/clean'
require 'rake/testtask'
require 'date'
require 'java'

desc "Build gem"
task :gem  do |t|
  gemspec = Gem::Specification.new do |s|
    s.name = 'jruby-jms'
    s.version = '0.11.0'
    s.author = 'Reid Morrison'
    s.email = 'rubywmq@gmail.com'
    s.homepage = 'https://github.com/reidmorrison/jruby-jms'
    s.date = Date.today.to_s
    s.description = 'JRuby-JMS is a Java and Ruby library that exposes the Java JMS API in a ruby friendly way. For JRuby only.'
    s.summary = 'JRuby interface into JMS'
    s.files = FileList["./**/*"].exclude('*.gem', './nbproject/*').map{|f| f.sub(/^\.\//, '')}
    s.has_rdoc = true
  end
  Gem::Builder.new(gemspec).build
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

