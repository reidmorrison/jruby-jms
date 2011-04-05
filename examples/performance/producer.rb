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
count = (ARGV[1] || 5).to_i

# Load Connection parameters from configuration file
config = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'jms.yml'))[jms_provider]
raise "JMS Provider option:#{jms_provider} not found in jms.yml file" unless config

JMS::Connection.session(config) do |session|
  start_time = Time.now
  
  session.producer(:queue_name => 'SampleQueue') do |producer|
    count.times do |i| 
      producer.send(session.message("Hello Producer #{i}"))
    end
  end

  duration = Time.now - start_time
  puts "Delivered #{count} messages in #{duration} seconds at #{count/duration} messages per second"
end
