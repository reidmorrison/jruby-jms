#
# Sample Producer:
#   Write messages to the queue
#
require 'yaml'
require 'jms'

jms_provider = ARGV[0] || 'activemq'

# Load Connection parameters from configuration file
config       = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'jms.yml'))[jms_provider]
raise "JMS Provider option:#{jms_provider} not found in jms.yml file" unless config

JMS::Connection.session(config) do |session|
  session.producer(:queue_name => 'ExampleQueue') do |producer|
    producer.delivery_mode_sym = :non_persistent
    producer.send(session.message("Hello World: #{Time.now}"))
    JMS.logger.info 'Successfully sent one message to queue ExampleQueue'
  end
end
