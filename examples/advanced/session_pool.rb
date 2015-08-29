#
# How to use the session pool in a multi-threaded application such as Rails
#   This example shows how to have multiple producers publishing information
#   to topics
#
require 'yaml'
require 'jms'
# Also add 'gene_pool' to list of gems in Gemfile
require 'gene_pool'

jms_provider = ARGV[0] || 'activemq'

### This part would typically go in a Rails Initializer ###

# Load Connection parameters from configuration file
config       = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'jms.yml'))[jms_provider]
raise "JMS Provider option:#{jms_provider} not found in jms.yml file" unless config

JMS_CONNECTION = JMS::Connection.new(config)
JMS_CONNECTION.start
JMS_SESSION_POOL = JMS_CONNECTION.create_session_pool(config)

# Ensure connections are released if application is shutdown
at_exit do
  JMS_SESSION_POOL.close
  JMS_CONNECTION.close
end

### This part would typically go in the Rails Model ###

JMS_SESSION_POOL.producer(queue_name: 'SampleQueue') do |session, producer|
  producer.send(session.message('Hello World'))
end

