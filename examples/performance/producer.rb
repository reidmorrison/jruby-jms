#
# Sample Producer:
#   Write multiple messages to the queue
#

# Allow examples to be run in-place without requiring a gem install
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../../lib'

require 'rubygems'
require 'yaml'
require 'jms'
require 'benchmark'

jms_provider = ARGV[0] || 'activemq'
count = (ARGV[1] || 10).to_i

# Load Connection parameters from configuration file
config = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'jms.yml'))[jms_provider]
raise "JMS Provider option:#{jms_provider} not found in jms.yml file" unless config

JMS::Connection.session(config) do |session|
  duration = Benchmark.realtime do
    session.producer(:queue_name => 'ExampleQueue') do |producer|
      count.times do |i|
        producer.send(session.message("Hello Producer #{i}"))
      end
    end
  end

  JMS::logger.info "Produced #{count} messages. Average #{duration*1000/count}ms per message"
end
