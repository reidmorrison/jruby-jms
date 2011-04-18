#
# Sample Producer:
#   Write messages to the queue
#

# Allow examples to be run in-place without requiring a gem install
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../../lib'

require 'rubygems'
require 'yaml'
require 'jms'

jms_provider = ARGV[0] || 'activemq'

# Load Connection parameters from configuration file
config = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'jms.yml'))[jms_provider]
raise "JMS Provider option:#{jms_provider} not found in jms.yml file" unless config

JMS::Connection.session(config) do |session|
  session.producer(:queue_name => 'ExampleQueue') do |producer|
    producer.delivery_mode = JMS::DeliveryMode::NON_PERSISTENT
    producer.send(session.message("Hello World: #{Time.now}"))
    JMS::logger.info "Successfully sent one message to queue ExampleQueue"
  end
end
