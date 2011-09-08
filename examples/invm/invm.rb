#
# Sample ActiveMQ InVM Example:
#   Write to a queue and then consume the message in a separate thread
#
# Note: This example only works with ActiveMQ
#       Update the jar files path in ../jms.yml to point to your ActiveMQ installation

# Allow examples to be run in-place without requiring a gem install
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../../lib'

require 'rubygems'
require 'yaml'
require 'jms'
require 'benchmark'

# Set Log4J properties file so that it does not need to be in the CLASSPATH
java.lang.System.properties['log4j.configuration'] = "file://#{File.join(File.dirname(__FILE__), 'log4j.properties')}"

jms_provider = 'activemq-invm'

# Load Connection parameters from configuration file
config = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'jms.yml'))[jms_provider]
raise "JMS Provider option:#{jms_provider} not found in jms.yml file" unless config

JMS::Connection.start(config) do |connection|
  # Consume messages in a separate thread
  connection.on_message(:queue_name => 'ExampleQueue') do |message|
    JMS::logger.info "Consumed message from ExampleQueue: '#{message.data}'"
  end

  # Send a single message within a new session
  connection.session do |session|
    session.producer(:queue_name => 'ExampleQueue') do |producer|
      producer.send(session.message("Hello World. #{Time.now}"))
    end
  end

  JMS::logger.info "Put message on ExampleQueue"

  # Give the consume thread time to process the message before terminating
  sleep 1

  JMS::logger.info "Shutting down"
end
