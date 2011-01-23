#
# Sample Producer:
#   Write messages to the queue
#

# Allow examples to be run in-place without requiring a gem install
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'jms'

jms_provider = ARGV[0] || 'default'

# Load Connection parameters from configuration file
config = YAML.load_file(File.join(File.dirname(__FILE__), 'jms.yml'))[jms_provider]
raise "JMS Provider option:#{jms_provider} not found in jms.yml file" unless config

JMS::Connection.create_session(config) do |session|
  session.producer(:q_name => 'ExampleQueue') do |producer|
    producer.send(session.message("Hello World"))
  end
end
