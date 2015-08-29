#
# Sample request/reply pattern requestor implementation:
# Basically what this does is:
# 1) Create temporary Queue to MQ Session
# 2) Create consumer to session (This is important to be up before producer to make sure response isn't available before consumer is up)
# 3) Create producer to session
# 4) Create message for session
# 5) Set message's JMSReplyTo to point to the temporary queue created in #1
# 6) Send message to send queue
# 7) Consume the first message available from the temporary queue within the time set in :timeout
# 8) Close temporary queue, consumer, producer and session by ending the blocks
#
require 'yaml'
require 'jms'

jms_provider = ARGV[0] || 'activemq'

# Load Connection parameters from configuration file
config       = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'jms.yml'))[jms_provider]
raise "JMS Provider option:#{jms_provider} not found in jms.yml file" unless config

JMS::Connection.session(config) do |session|
  session.temporary_queue do |temporary_queue|
    session.consumer(destination: temporary_queue) do |consumer|
      session.producer(queue_name: 'ExampleQueue') do |producer|
        message              = session.message('Hello World')
        message.jms_reply_to = temporary_queue
        producer.send(message)
      end
      # Using timeout of 5seconds here
      response_message = consumer.get(timeout: 5000)
      # Get message data as response if response_message is available
      response         = response_message != nil ? response_message.data : nil
      p response
    end
  end
end
