#
# Example: q_to_files:
#  Copy all messages in a queue to separate files in a directory
#  The messages are left on the queue by
#
#  jruby q_to_files.rb activemq my_queue
#
require 'jms'
require 'yaml'
require 'fileutils'

raise("Required Parameters: 'jms_provider' 'queue_name' 'output_directory'") unless ARGV.count >= 2
jms_provider = ARGV[0]
queue_name   = ARGV[1]
path         = ARGV[2] || queue_name

# Load Connection parameters from configuration file
config       = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'jms.yml'))[jms_provider]
raise "JMS Provider option:#{jms_provider} not found in jms.yml file" unless config

# Create supplied path if it does not exist
FileUtils.mkdir_p(path)

counter = 0
# Consume all available messages on the queue
JMS::Connection.session(config) do |session|
  session.browse(:queue_name => queue_name, :timeout => 1000) do |message|
    counter  += 1
    filename = File.join(path, 'message_%03d' % counter)
    File.open(filename+'.data', 'wb') { |file| file.write(message.data) }
    header = {
      :attributes => message.attributes,
      :properties => message.properties
    }
    File.open(filename+'.yml', 'wb') { |file| file.write(header.to_yaml) }
  end
end

puts "Saved #{counter} messages to #{path}"
