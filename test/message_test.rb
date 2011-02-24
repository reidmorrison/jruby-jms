# Allow examples to be run in-place without requiring a gem install
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'jms'
require 'yaml'

class JMSTest < Test::Unit::TestCase
  context 'JMS Session' do
    # Load configuration from jms.yml
    setup do
      # To change the JMS provider, edit jms.yml and change :default
      
      # Load Connection parameters from configuration file
      cfg = YAML.load_file(File.join(File.dirname(__FILE__), 'jms.yml'))
      jms_provider = cfg['default']
      @config = cfg[jms_provider]
      raise "JMS Provider option:#{jms_provider} not found in jms.yml file" unless @config
      @queue_name = @config[:queue_name] || raise("Mandatory :queue_name missing from jms.yml")
      @topic_name = @config[:topic_name] || raise("Mandatory :topic_name missing from jms.yml")
    end
    
    should 'produce and consume messages to/from a temporary queue' do
      JMS::Connection.session(@config) do |session|
        assert_not_nil session
        data = nil
        session.producer(:queue_name => :temporary) do |producer|
          # Send Message
          producer.send(session.message('Hello World'))
          
          # Consume Message
          session.consume(:destination => producer.destination) do |message|
            assert_equal message.java_kind_of?(javax.jms::TextMessage), true
            data = message.data
          end
        end
        assert_equal data, 'Hello World'
      end
    end

    should 'produce, browse and consume messages to/from a queue' do
      JMS::Connection.session(@config) do |session|
        assert_not_nil session
        data = :timed_out
        browse_data = nil
        session.producer(:queue_name => @queue_name) do |producer|
          # Send Message
          producer.send(session.message('Hello World'))
          
          # Browse Message
          session.browse(:queue_name => @queue_name) do |message|
            assert_equal message.java_kind_of?(javax.jms::TextMessage), true
            browse_data = message.data
          end
          
          # Consume Message
          session.consume(:queue_name => @queue_name) do |message|
            assert_equal message.java_kind_of?(javax.jms::TextMessage), true
            data = message.data
          end
        end
        assert_equal 'Hello World', data
        assert_equal 'Hello World', browse_data
      end
    end

    should 'support setting persistence using symbols and the java constants' do
      JMS::Connection.session(@config) do |session|
        message = session.message('Hello World')
        assert_equal message.jms_delivery_mode, :non_persistent
        message.jms_delivery_mode = :non_persistent
        assert_equal message.jms_delivery_mode, :non_persistent
        message.jms_delivery_mode = :persistent
        assert_equal message.jms_delivery_mode, :persistent
      end
    end  
      
    should 'produce and consume non-persistent messages' do
      JMS::Connection.session(@config) do |session|
        assert_not_nil session
        data = nil
        session.producer(:queue_name => :temporary) do |producer|
          message = session.message('Hello World')
          message.jms_delivery_mode = :non_persistent
          assert_equal :non_persistent, message.jms_delivery_mode
          assert_equal false, message.persistent?
          
          # Send Message
          producer.send(message)
          
          # Consume Message
          session.consume(:destination => producer.destination) do |message|
            assert_equal message.java_kind_of?(javax.jms::TextMessage), true
            data = message.data
            #assert_equal :non_persistent, message.jms_delivery_mode
            #assert_equal false, message.persistent?
          end
        end
        assert_equal data, 'Hello World'
      end
    end

    should 'produce and consume persistent messages' do
      JMS::Connection.session(@config) do |session|
        assert_not_nil session
        data = nil
        session.producer(:queue_name => :temporary) do |producer|
          message = session.message('Hello World')
          message.jms_delivery_mode = :persistent
          assert_equal :persistent, message.jms_delivery_mode
          assert_equal true, message.persistent?
          
          # Send Message
          producer.send(message)
          
          # Consume Message
          session.consume(:destination => producer.destination) do |message|
            assert_equal message.java_kind_of?(javax.jms::TextMessage), true
            data = message.data
            assert_equal :persistent, message.jms_delivery_mode
            assert_equal true, message.persistent?
          end
        end
        assert_equal data, 'Hello World'
      end
    end

  end
end
