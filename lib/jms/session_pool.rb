require 'gene_pool'

module JMS
  # Since a Session can only be used by one thread at a time, we could create
  # a Session for every thread. That could result in excessive unused Sessions.
  # An alternative is to create a pool of sessions that can be shared by
  # multiple threads.
  #
  # Each thread can request a session and then return it once it is no longer
  # needed by that thread. The only way to get a session is pass a block so that
  # the Session is automatically returned to the pool upon completion of the block.
  #
  # Parameters:
  #   see regular session parameters from: JMS::Connection#initialize
  #
  # Additional parameters for controlling the session pool itself
  #   :pool_name         Name of the pool as it shows up in the logger.
  #                      Default: 'JMS::SessionPool'
  #   :pool_size         Maximum Pool Size. Default: 10
  #                      The pool only grows as needed and will never exceed
  #                      :pool_size
  #   :pool_warn_timeout Number of seconds to wait before logging a warning when a
  #                      session in the pool is not available. Measured in seconds
  #                      Default: 5.0
  #   :pool_logger       Supply a logger that responds to #debug, #info, #warn and #debug?
  #                      For example: Rails.logger
  #                      Default: None
  # Example:
  #   session_pool = connection.create_session_pool(config)
  #   session_pool.session do |session|
  #      ....
  #   end
  class SessionPool
    def initialize(connection, params={})
      # Save Session params since it will be used every time a new session is
      # created in the pool
      session_params = params.nil? ? {} : params.dup
      logger = session_params[:pool_logger]
      # Define how GenePool can create new sessions
      @pool = GenePool.new(
        :name => session_params[:pool_name] || self.class.name,
        :pool_size => session_params[:pool_size] || 10,
        :warn_timeout => session_params[:pool_warn_timeout] || 5,
        :logger       => logger) do
        connection.create_session(session_params)
      end

      # Handle connection failures
      connection.on_exception do |jms_exception|
        logger.error "JMS Connection Exception has occurred: #{jms_exception}"
        #TODO: Close all sessions in the pool and release from the pool?
      end
    end

    # Obtain a session from the pool and pass it to the supplied block
    # The session is automatically returned to the pool once the block completes
    def session(&block)
      #TODO Check if session is open?
      @pool.with_connection &block
      #TODO Catch connection failures and release from pool?
    end

    # Obtain a session from the pool and create a MessageConsumer.
    # Pass both into the supplied block.
    # Once the block is complete the consumer is closed and the session is
    # returned to the pool.
    #
    # Parameters:
    #   :queue_name => String: Name of the Queue to return
    #                  Symbol: :temporary => Create temporary queue
    #                  Mandatory unless :topic_name is supplied
    #     Or,
    #   :topic_name => String: Name of the Topic to write to or subscribe to
    #                  Symbol: :temporary => Create temporary topic
    #                  Mandatory unless :queue_name is supplied
    #     Or,
    #   :destination=> Explicit javaxJms::Destination to use
    #
    #   :selector   => Filter which messages should be returned from the queue
    #                  Default: All messages
    #   :no_local   => Determine whether messages published by its own connection
    #                  should be delivered to it
    #                  Default: false
    #
    # Example
    #   session_pool.consumer(:queue_name => 'MyQueue') do |session, consumer|
    #     message = consumer.receive(timeout)
    #     puts message.data if message
    #   end
    def consumer(params, &block)
      session do |s|
        consumer = nil
        begin
          consumer = s.consumer(params)
          block.call(s, consumer)
        ensure
          consumer.close if consumer
        end
      end
    end

    # Obtain a session from the pool and create a MessageProducer.
    # Pass both into the supplied block.
    # Once the block is complete the producer is closed and the session is
    # returned to the pool.
    #
    # Parameters:
    #   :queue_name => String: Name of the Queue to send messages to
    #                  Symbol: :temporary => Create temporary queue
    #                  Mandatory unless :topic_name is supplied
    #     Or,
    #   :topic_name => String: Name of the Topic to send message to
    #                  Symbol: :temporary => Create temporary topic
    #                  Mandatory unless :queue_name is supplied
    #     Or,
    #   :destination=> Explicit JMS::Destination to use
    #
    # Example
    #   session_pool.producer(:queue_name => 'ExampleQueue') do |session, producer|
    #     producer.send(session.message("Hello World"))
    #   end
    def producer(params, &block)
      session do |s|
        producer = nil
        begin
          producer = s.producer(params)
          block.call(s, producer)
        ensure
          producer.close if producer
        end
      end
    end

    # Immediately Close all sessions in the pool and release from the pool
    #
    # TODO: Allow an option to wait for active sessions to be returned before
    #       closing
    def close
      @pool.each do |s|
        #@pool.remove(s)
        s.close
        #@pool.remove(s)
      end
    end

  end

end