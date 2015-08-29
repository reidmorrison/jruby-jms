#
# Sample Topic Subscriber:
#   Retrieve all messages from a topic using a non-durable subscription
#
# Try starting multiple copies of this Consumer. All active instances should
# receive the same messages
#
# Since the topic subscription is non-durable, it will only receive new messages.
# Any messages sent prior to the instance starting will not be received.
# Also, any messages sent after the instance has stopped will not be received
# when the instance is re-started, only new messages sent after it started will
# be received.
require 'jms'
require 'yaml'

jms_provider = ARGV[0] || 'activemq'

# Load Connection parameters from configuration file
config       = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'jms.yml'))[jms_provider]
raise "JMS Provider option:#{jms_provider} not found in jms.yml file" unless config

JMS::Connection.session(config) do |session|
  session.consume(topic_name: 'SampleTopic', timeout: 30000) do |message|
    JMS.logger.info message.inspect
  end
end
