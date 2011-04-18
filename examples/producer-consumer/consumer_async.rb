#
# Sample Asynchronous Consumer:
#   Retrieve all messages from the queue in a separate thread
#

# Allow examples to be run in-place without requiring a gem install
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../../lib'

require 'rubygems'
require 'jms'
require 'yaml'

jms_provider = ARGV[0] || 'activemq'

# Load Connection parameters from configuration file
config = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'jms.yml'))[jms_provider]
raise "JMS Provider option:#{jms_provider} not found in jms.yml file" unless config

# Consume all available messages on the queue
JMS::Connection.start(config) do |connection|
  
  # Define Asynchronous code block to be called every time a message is receive
  connection.on_message(:queue_name => 'ExampleQueue') do |message|
    JMS::logger.info message.inspect
  end

  # Since the on_message handler above is in a separate thread the thread needs
  # to do some other work. For this example it will just sleep for 10 seconds
  sleep 10
end
