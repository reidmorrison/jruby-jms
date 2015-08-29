#
# Sample Browsing Consumer:
#   Browse all messages on a queue without removing them
#
require 'jms'
require 'yaml'

jms_provider = ARGV[0] || 'activemq'

# Load Connection parameters from configuration file
config       = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'jms.yml'))[jms_provider]
raise "JMS Provider option:#{jms_provider} not found in jms.yml file" unless config

# Consume all available messages on the queue
JMS::Connection.session(config) do |session|
  session.browse(queue_name: 'ExampleQueue', timeout: 1000) do |message|
    JMS.logger.info message.inspect
  end
end
