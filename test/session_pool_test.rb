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
      @queue_name = @config.delete(:queue_name) || raise("Mandatory :queue_name missing from jms.yml")
      @topic_name = @config.delete(:topic_name) || raise("Mandatory :topic_name missing from jms.yml")
      @pool_params = {
        :pool_name         => 'Test::JMS::SessionPool',
        :pool_size         => 10,
        :pool_warn_timeout => 5.0,
        #:pool_logger       =>
      }
    end

    should 'create a session pool' do
      JMS::Connection.start(@config) do |connection|
        pool = connection.create_session_pool(@pool_params)
        pool.session do |session|
          assert_not_nil session
          assert session.is_a?(javax.jms.Session)
        end
        pool.close
      end
    end

    should 'remove bad session from pool' do
      JMS::Connection.start(@config) do |connection|
        pool = connection.create_session_pool(@pool_params.merge(:pool_size=>1))
        s = nil
        r = begin
          pool.session do |session|
            assert_not_nil session
            assert session.is_a?(javax.jms.Session)
            s = session
            s.close
            s.create_map_message
            false
          end
        rescue javax.jms.IllegalStateException
          true
        end
        assert r == true

        # Now verify that the previous closed session was removed from the pool
        pool.session do |session|
          assert_not_nil session
          assert session.is_a?(javax.jms.Session)
          assert s != session
          session.create_map_message
        end
      end
    end

    should 'allow multiple sessions to be used concurrently' do
      JMS::Connection.start(@config) do |connection|
        pool = connection.create_session_pool(@pool_params)
        pool.session do |session|
          assert_not_nil session
          assert session.is_a?(javax.jms.Session)
          pool.session do |session2|
            assert_not_nil session2
            assert session2.is_a?(javax.jms.Session)
            assert session != session2
          end
        end
      end
    end

  end
end
