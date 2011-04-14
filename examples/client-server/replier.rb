#
# Sample request/reply pattern replier:
# Basically does the following:
# 1) Consume messages from ExampleQueue indefinitely
# 2) Get JMSReplyTo from consumed message
# 3) Produce and send response to received message
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

JMS::Connection.session(config) do |session|
  session.consume(:queue_name => "ExampleQueue", :timeout => -1) do |message|
    p "Got message: #{message.data}. Replying politely."
    session.producer(:destination => message.reply_to) do |producer|
      producer.send(session.message("Hello to you too!"))
    end
  end
end
