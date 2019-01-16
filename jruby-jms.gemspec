lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

# Maintain gem's version:
require 'jms/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'jruby-jms'
  spec.version     = JMS::VERSION
  spec.platform    = 'java'
  spec.authors     = ['Reid Morrison']
  spec.email       = ['reidmo@gmail.com']
  spec.homepage    = 'https://github.com/reidmorrison/jruby-jms'
  spec.summary     = 'JRuby interface into JMS'
  spec.description = 'jruby-jms is a complete JRuby API into Java Messaging Specification (JMS) V1.1. For JRuby only.'
  spec.files       = Dir['lib/**/*', 'bin/*', 'LICENSE.txt', 'Rakefile', 'README.md', 'HISTORY.md']
  spec.test_files  = Dir['test/**/*']
  spec.license     = 'Apache-2.0'
  spec.has_rdoc    = true
  spec.add_dependency 'gene_pool'
  spec.add_dependency 'semantic_logger'
end
