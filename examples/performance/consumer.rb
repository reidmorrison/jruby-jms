#
# Sample Consumer:
#   Retrieve all messages from a queue
#
require 'yaml'
require 'jms'

jms_provider = ARGV[0] || 'activemq'

# Load Connection parameters from configuration file
config       = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'jms.yml'))[jms_provider]
raise "JMS Provider option:#{jms_provider} not found in jms.yml file" unless config

JMS::Connection.session(config) do |session|
  stats = session.consume(queue_name: 'ExampleQueue', statistics: true) do |message|
    # Do nothing in this example with each message
  end

  JMS.logger.info "Consumed #{stats[:messages]} messages. Average #{stats[:ms_per_msg]}ms per message"
end
