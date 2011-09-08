#
# Example : files_to_q : Place all files in a directory to a queue
#     Each file is written as a separate message
#     Place the data in a file ending with '.data'
#     and the header information in a file with same name, but with an
#     extension of '.yml'
#
#  jruby files_to_q.rb activemq my_queue
#

# Allow examples to be run in-place without requiring a gem install
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../../lib'

require 'rubygems'
require 'jms'
require 'yaml'

raise("Required Parameters: 'jms_provider' 'queue_name' 'input_directory'") unless ARGV.count >= 2
jms_provider = ARGV[0]
queue_name = ARGV[1]
path = ARGV[2] || queue_name

# Load Connection parameters from configuration file
config = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'jms.yml'))[jms_provider]
raise "JMS Provider option:#{jms_provider} not found in jms.yml file" unless config

counter = 0
# Consume all available messages on the queue
JMS::Connection.session(config) do |session|
  session.producer(:queue_name => queue_name) do |producer|
    Dir.glob(File.join(path,'*.data')) do |filename|
      unless File.directory?(filename)
        printf("%5d: #{filename}\n",counter = counter + 1)
        data = File.open(filename, 'rb') {|file| file.read }
        header_filename = File.join(File.dirname(filename), File.basename(filename))
        header_filename = header_filename[0, header_filename.length - '.data'.length] + '.yml'
        header = File.exist?(header_filename) ? YAML.load_file(header_filename) : nil
        message = session.message(data, :bytes)
        if header
          header[:attributes].each_pair do |k,v|
            next if k == :jms_destination
            message.send("#{k}=".to_sym, v) if message.respond_to?("#{k}=".to_sym)
          end if header[:attributes]
          message.properties = header[:properties] || {}
        end
        producer.send(message)
      end
    end
 end
end
puts "Read #{counter} messages from #{path} and wrote to #{queue_name}"
