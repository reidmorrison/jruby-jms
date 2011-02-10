# Allow examples to be run in-place without requiring a gem install
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'jms'
require 'yaml'

class JMSTest < Test::Unit::TestCase
  context '' do
    # Load configuration from jms.yml
    setup do
      jms_provider =  'activemq'  # TODO Make Environment Variable configurable

      # Load Connection parameters from configuration file
      @config = YAML.load_file(File.join(File.dirname(__FILE__), 'jms.yml'))[jms_provider]
      raise "JMS Provider option:#{jms_provider} not found in jms.yml file" unless @config
    end

    should 'Create Connection to the Broker/Server' do
      connection = JMS::Connection.new(@config)
      assert_not_nil connection
      connection.close
    end

    should 'Create and start Connection to the Broker/Server with block' do
      JMS::Connection.start(@config) do |connection|
        assert_not_nil connection
      end
    end
   
    should 'Create and start Connection to the Broker/Server with block and start one session' do
      JMS::Connection.session(@config) do |session|
        assert_not_nil session 
      end
    end
    
    should 'Start and stop connection' do
      connection = JMS::Connection.new(@config)
      assert_not_nil connection
      assert_nil connection.start
      
      assert_nil connection.stop
      assert_nil connection.close
    end

#    # Tests
#    # 
#
#    should 'Write one message to a queue' do
#      JMS::Connection.session(@config) do |session|
#        session.producer(:q_name => 'ExampleQueue') do |producer|
#          producer.send(session.message("Hello World"))
#        end
#      end
#    end

  end
end
