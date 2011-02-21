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

    should 'create a session' do
      JMS::Connection.session(@config) do |session|
        assert_not_nil session
      end
    end

    should 'create automatic messages' do
      JMS::Connection.session(@config) do |session|
        assert_not_nil session
        # Create Text Message
        assert_equal session.message("Hello").java_kind_of?(javax.jms::TextMessage), true
          
        # Create Map Message
        assert_equal session.message('hello'=>'world').java_kind_of?(javax.jms::MapMessage), true
      end
    end

    should 'create explicit messages' do
      JMS::Connection.session(@config) do |session|
        assert_not_nil session
        # Create Text Message
        assert_equal session.create_text_message("Hello").java_kind_of?(javax.jms::TextMessage), true
          
        # Create Map Message
        assert_equal session.create_map_message.java_kind_of?(javax.jms::MapMessage), true
      end
    end
    
    should 'create temporary destinations in blocks' do
      JMS::Connection.session(@config) do |session|
        assert_not_nil session
        
        # Temporary Queue
        session.destination(:queue_name => :temporary) do |destination|
          assert_equal destination.java_kind_of?(javax.jms::TemporaryQueue), true
        end
          
        # Temporary Topic
        session.create_destination(:topic_name => :temporary) do |destination|
          assert_equal destination.java_kind_of?(javax.jms::TemporaryTopic), true
        end
      end
    end
    
    should 'create temporary destinations' do
      JMS::Connection.session(@config) do |session|
        assert_not_nil session
        
        # Temporary Queue
        destination = session.create_destination(:queue_name => :temporary)
        assert_equal destination.java_kind_of?(javax.jms::TemporaryQueue), true
        destination.delete
          
        # Temporary Topic
        destination = session.create_destination(:topic_name => :temporary)
        assert_equal destination.java_kind_of?(javax.jms::TemporaryTopic), true
        destination.delete
      end
    end
    
    should 'create destinations in blocks' do
      JMS::Connection.session(@config) do |session|
        assert_not_nil session
        
        # Temporary Queue
        session.destination(:queue_name => @queue_name) do |destination|
          assert_equal destination.java_kind_of?(javax.jms::Queue), true
        end
          
        # Temporary Topic
        session.create_destination(:topic_name => @topic_name) do |destination|
          assert_equal destination.java_kind_of?(javax.jms::Topic), true
        end
      end
    end
    
    should 'create destinations' do
      JMS::Connection.session(@config) do |session|
        assert_not_nil session
        
        # Queue
        queue = session.create_destination(:queue_name => @queue_name)
        assert_equal queue.java_kind_of?(javax.jms::Queue), true
          
        # Topic
        topic = session.create_destination(:topic_name => @topic_name)
        assert_equal topic.java_kind_of?(javax.jms::Topic), true
      end
    end
    
    should 'create destinations using direct methods' do
      JMS::Connection.session(@config) do |session|
        assert_not_nil session
        
        # Queue
        queue = session.queue(@queue_name)
        assert_equal queue.java_kind_of?(javax.jms::Queue), true
          
        # Temporary Queue
        queue = session.temporary_queue
        assert_equal queue.java_kind_of?(javax.jms::TemporaryQueue), true
        queue.delete
        
        # Topic
        topic = session.topic(@topic_name)
        assert_equal topic.java_kind_of?(javax.jms::Topic), true
        
        # Temporary Topic
        topic = session.temporary_topic
        assert_equal topic.java_kind_of?(javax.jms::TemporaryTopic), true
        topic.delete
      end
    end
    
  end
end
