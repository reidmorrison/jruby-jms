################################################################################
#  Copyright 2008, 2009, 2010, 2011  J. Reid Morrison
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
################################################################################

# For each thread that will be processing messages concurrently a separate
# session is required. All sessions can share a single connection to the same
# JMS Provider.
# 
# Interface javax.jms.Session
module Java::javaxJms::Session
  # Create a new message instance based on the type of the data being supplied
  #   String (:to_str)    => TextMessage
  #   Hash   (:each_pair) => MapMessage
  # In fact duck typing is used to determine the type. If the class responds
  # to :to_str then it is considered a String. Similarly if it responds to
  # :each_pair it is considered to be a Hash
  def message(data)
    jms_message = nil
    if data.respond_to?(:to_str, false)
      jms_message = self.createTextMessage
      jms_message.text = data.to_str
    elsif data.respond_to?(:each_pair, false)
      jms_message = self.createMapMessage
      jms_message.data = data
    else
      raise "Unknown data type #{data.class.to_s} in Message"
    end
    jms_message
  end

  # Does the session support transactions?
  # I.e. Can/should commit and rollback be called
  def transacted?
    self.getAcknowledgeMode == Java::javax.jms.Session::SESSION_TRANSACTED
  end

  # Create and open a queue to put or get from. Once the supplied Proc is complete
  # the queue is automatically closed. If no Proc is supplied then the queue must
  # be explicitly closed by the caller.
  def destination(parms={}, &proc)
    parms[:jms_session] = self
    q = JMS::Destination.new(parms)
    q.open(parms)
    if proc
      begin
        proc.call(q)
      ensure
        q.close
        q = nil
      end
    end
    q
  end

  # Return the queue matching the queue name supplied
  # Call the Proc if supplied
  def queue(q_name, &proc)
    q = create_queue(q_name)
    if proc
      begin
        proc.call(q)
      ensure
        q = nil
      end
    end
    q
  end

  # Return a producer for the queue name supplied
  # A producer supports sending messages to a Queue or a Topic
  #
  # Call the Proc if supplied, then automatically close the producer
  #
  # Parameters:
  #   :q_name     => String: Name of the Queue to return
  #                  Symbol: :temporary => Create temporary queue
  #                  Mandatory unless :topic_name is supplied
  #     Or,
  #   :topic_name => String: Name of the Topic to write to or subscribe to
  #                  Symbol: :temporary => Create temporary topic
  #                  Mandatory unless :q_name is supplied
  #     Or,
  #   :destination=> Explicit Java::javaxJms::Destination to use
  def producer(parms, &proc)
    destination = create_destination(parms)
    p = create_producer(destination)
    if proc
      begin
        proc.call(p)
      ensure
        p.close
        p = nil
      end
    end
    p
  end

  # Return a consumer for the destination
  # A consumer can read messages from the queue or topic
  #
  # Call the Proc if supplied, then automatically close the consumer
  #
  # Parameters:
  #   :q_name     => String: Name of the Queue to return
  #                  Symbol: :temporary => Create temporary queue
  #                  Mandatory unless :topic_name is supplied
  #     Or,
  #   :topic_name => String: Name of the Topic to write to or subscribe to
  #                  Symbol: :temporary => Create temporary topic
  #                  Mandatory unless :q_name is supplied
  #     Or,
  #   :destination=> Explicit Java::javaxJms::Destination to use
  #
  #   :selector   => Filter which messages should be returned from the queue
  #                  Default: All messages
  #   :no_local   => Determine whether messages published by its own connection
  #                  should be delivered to it
  #                  Default: false
  def consumer(parms, &proc)
    destination = create_destination(parms)
    c = nil
    if parms[:no_local]
      c = create_consumer(destination, parms[:selector] || '', parms[:no_local])
    elsif parms[:selector]
      c = create_consumer(destination, parms[:selector])
    else
      c = create_consumer(destination)
    end

    if proc
      begin
        proc.call(c)
      ensure
        c.close
        c = nil
      end
    end
    c
  end

  # Consume all messages for the destination
  # A consumer can read messages from the queue or topic
  #
  # Parameters:
  #   :q_name     => String: Name of the Queue to return
  #                  Symbol: :temporary => Create temporary queue
  #                  Mandatory unless :topic_name is supplied
  #     Or,
  #   :topic_name => String: Name of the Topic to write to or subscribe to
  #                  Symbol: :temporary => Create temporary topic
  #                  Mandatory unless :q_name is supplied
  #     Or,
  #   :destination=> Explicit Java::javaxJms::Destination to use
  #
  #   :selector   => Filter which messages should be returned from the queue
  #                  Default: All messages
  #   :no_local   => Determine whether messages published by its own connection
  #                  should be delivered to it
  #                  Default: false
  #
  #   :timeout Follows the rules for MQSeries:
  #     -1 : Wait forever
  #      0 : Return immediately if no message is available
  #      x : Wait for x milli-seconds for a message to be received from the broker
  #           Note: Messages may still be on the queue, but the broker has not supplied any messages
  #                     in the time interval specified
  #      Default: 0
  #
  def consume(parms, &proc)
    c = self.consumer(parms)
    begin
      c.each(parms, &proc)
    ensure
      c.close
    end
  end

  # Return a browser for the destination
  # A browser can read messages non-destructively from the queue
  # It cannot browse Topics!
  #
  # Call the Proc if supplied, then automatically close the consumer
  #
  # Parameters:
  #   :q_name     => String: Name of the Queue to return
  #                  Symbol: :temporary => Create temporary queue
  #                  Mandatory unless :topic_name is supplied
  #     Or,
  #   :destination=> Explicit Java::javaxJms::Destination to use
  #
  #   :selector   => Filter which messages should be returned from the queue
  #                  Default: All messages
  def browser(parms, &proc)
    raise "Session::browser requires a code block to be executed" unless proc

    destination = create_destination(parms)
    b = nil
    if parms[:selector]
      b = create_browser(destination, parms[:selector])
    else
      b = create_browser(destination)
    end

    if proc
      begin
        proc.call(b)
      ensure
        b.close
        b = nil
      end
    end
    b
  end

  # Browse the specified queue, calling the Proc supplied for each message found
  #
  # Parameters:
  #   :q_name     => String: Name of the Queue to return
  #                  Symbol: :temporary => Create temporary queue
  #                  Mandatory unless :topic_name is supplied
  #     Or,
  #   :destination=> Explicit Java::javaxJms::Destination to use
  #
  #   :selector   => Filter which messages should be returned from the queue
  #                  Default: All messages
  def browse(parms={}, &proc)
    self.browser(parms) {|b| b.each(parms, &proc)}
  end

  private
  # Create the destination based on the parameter supplied
  #
  # Parameters:
  #   :q_name     => String: Name of the Queue to return
  #                  Symbol: :temporary => Create temporary queue
  #                  Mandatory unless :topic_name is supplied
  #     Or,
  #   :topic_name => String: Name of the Topic to write to or subscribe to
  #                  Symbol: :temporary => Create temporary topic
  #                  Mandatory unless :q_name is supplied
  #     Or,
  #   :destination=> Explicit Java::javaxJms::Destination to use
  def create_destination(parms)
    return parms[:destination] if parms[:destination] && parms[:destination].kind_of?(Java::javaxJms::Destination)
    q_name = parms[:q_name]
    topic_name = parms[:topic_name]
    raise "Missing mandatory parameter :q_name or :topic_name to Session::producer, Session::consumer, or Session::browser" unless q_name || topic_name

    if q_name
      q_name == :temporary ? create_temporary_queue : create_queue(q_name)
    else
      topic_name == :temporary ? create_temporary_topic : create_topic(topic_name)
    end
  end
end

# Workaround for IBM MQ JMS implementation that implements an undocumented consume method
if defined? Java::ComIbmMqJms::MQSession
  class Java::ComIbmMqJms::MQSession
    def consume(parms, &proc)
      result = nil
      c = self.consumer(parms)
      begin
        result = c.each(parms, &proc)
      ensure
        c.close
      end
      result
    end
  end
end
