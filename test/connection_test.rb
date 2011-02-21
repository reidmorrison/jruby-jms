# Allow examples to be run in-place without requiring a gem install
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'jms'
require 'yaml'

class JMSTest < Test::Unit::TestCase
  context 'JMS Connection' do
    # Load configuration from jms.yml
    setup do
      # To change the JMS provider, edit jms.yml and change :default
      
      # Load Connection parameters from configuration file
      cfg = YAML.load_file(File.join(File.dirname(__FILE__), 'jms.yml'))
      jms_provider = cfg['default']
      @config = cfg[jms_provider]
      raise "JMS Provider option:#{jms_provider} not found in jms.yml file" unless @config
    end

    should 'Create Connection to the Broker/Server' do
      connection = JMS::Connection.new(@config)
      JMS::logger.info connection.to_s
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

    should 'Create a session from the connection' do
      connection = JMS::Connection.new(@config)
      
      session_parms = { 
        :transacted => true,
        :options => javax.jms.Session::AUTO_ACKNOWLEDGE
      }

      session = connection.create_session
      assert_not_nil session
      assert_equal session.transacted?, false
      assert_nil session.close
      
      assert_nil connection.stop
      assert_nil connection.close
    end

    should 'Create a session with a block' do
      connection = JMS::Connection.new(@config)
      
      connection.session do |session|
        assert_not_nil session
        assert_equal session.transacted?, false
      end
      
      assert_nil connection.stop
      assert_nil connection.close
    end

    should 'create a session without a block and throw exception' do
      connection = JMS::Connection.new(@config)
      
      assert_raise(RuntimeError) { connection.session }
      
      assert_nil connection.stop
      assert_nil connection.close
    end

    should 'Create a session from the connection with params' do
      connection = JMS::Connection.new(@config)
      
      session_parms = { 
        :transacted => true,
        :options => javax.jms.Session::AUTO_ACKNOWLEDGE
      }

      session = connection.create_session(session_parms)
      assert_not_nil session
      assert_equal session.transacted?, true
      # When session is transacted, options are ignore, so ack mode must be transacted
      assert_equal session.acknowledge_mode, javax.jms.Session::SESSION_TRANSACTED
      assert_nil session.close
      
      assert_nil connection.stop
      assert_nil connection.close
    end

    should 'Create a session from the connection with block and params' do
      JMS::Connection.start(@config) do |connection|
      
        session_parms = { 
          :transacted => true,
          :options => javax.jms.Session::CLIENT_ACKNOWLEDGE
        }

        connection.session(session_parms) do |session|
          assert_not_nil session
          assert_equal session.transacted?, true
          # When session is transacted, options are ignore, so ack mode must be transacted
          assert_equal session.acknowledge_mode, javax.jms.Session::SESSION_TRANSACTED
        end
      end
    end

    should 'Create a session from the connection with block and params opposite test' do
      JMS::Connection.start(@config) do |connection|
      
        session_parms = { 
          :transacted => false,
          :options => javax.jms.Session::AUTO_ACKNOWLEDGE
        }

        connection.session(session_parms) do |session|
          assert_not_nil session
          assert_equal session.transacted?, false
          assert_equal session.acknowledge_mode, javax.jms.Session::AUTO_ACKNOWLEDGE
        end
      end
    end
  
    context 'JMS Connection additional capabilities' do
    
      should 'start an on_message handler' do
        JMS::Connection.start(@config) do |connection|
          value = nil
          connection.on_message(:transacted => true, :queue_name => :temporary) do |message|
            value = "received"
          end
        end
      end
      
    end
    
  end
end
