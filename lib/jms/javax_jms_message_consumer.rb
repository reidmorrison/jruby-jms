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

module Java::javaxJms::MessageConsumer
  # Obtain a message from the Destination or Topic
  # In JMS terms, the message is received from the Destination
  # :timeout follows the rules for MQSeries:
  #   -1 : Wait forever
  #    0 : Return immediately if no message is available
  #    x : Wait for x milli-seconds for a message to be received from the broker
  #         Note: Messages may still be on the queue, but the broker has not supplied any messages
  #                   in the time interval specified
  #    Default: 0
  def get(parms={})
    timeout = parms[:timeout] || 0
    if timeout == -1
      self.receive
    elsif timeout == 0
      self.receiveNoWait
    else
      self.receive(timeout)
    end
  end

  # For each message available to be consumed call the Proc supplied
  # Returns the statistics gathered when :statistics => true, otherwise nil
  #
  # Parameters:
  #   :timeout How to timeout waiting for messages on the Queue or Topic
  #     -1 : Wait forever
  #      0 : Return immediately if no message is available
  #      x : Wait for x milli-seconds for a message to be received from the broker
  #           Note: Messages may still be on the queue, but the broker has not supplied any messages
  #                     in the time interval specified
  #      Default: 0
  #
  #   :statistics Capture statistics on how many messages have been read
  #      true  : This method will capture statistics on the number of messages received
  #              and the time it took to process them.
  #              The statistics can be reset by calling MessageConsumer::each again
  #              with :statistics => true
  #
  #              The statistics gathered are returned when :statistics => true and :async => false
  def each(parms={}, &proc)
    raise "Destination::each requires a code block to be executed for each message received" unless proc

    message_count = nil
    start_time = nil

    if parms[:statistics]
      message_count = 0
      start_time = Time.now
    end

    # Receive messages according to timeout
    while message = self.get(parms) do
      proc.call(message)
      message_count += 1 if message_count
    end

    unless message_count.nil?
      duration = Time.now - start_time
      {:messages => message_count,
        :duration => duration,
        :messages_per_second => (message_count/duration).to_i}
    end
  end

  # Receive messages in a separate thread when they arrive
  # Allows messages to be recieved in a separate thread. I.e. Asynchronously
  # This method will return to the caller before messages are processed.
  # It is then the callers responsibility to keep the program active so that messages
  # can then be processed.
  #
  # Parameters:
  #   :statistics Capture statistics on how many messages have been read
  #      true  : This method will capture statistics on the number of messages received
  #              and the time it took to process them.
  #              The timer starts when each() is called and finishes when either the last message was received,
  #              or when Destination::statistics is called. In this case MessageConsumer::statistics
  #              can be called several times during processing without affecting the end time.
  #              Also, the start time and message count is not reset until MessageConsumer::each
  #              is called again with :statistics => true
  #
  #              The statistics gathered are returned when :statistics => true and :async => false
  #
  def on_message(parms={}, &proc)
    raise "MessageConsumer::on_message requires a code block to be executed for each message received" unless proc

    @listener = JMS::MessageListener.new(parms,&proc)
    self.setMessageListener @listener
  end

  # Return the current statistics for a running MessageConsumer::on_message
  def on_message_statistics
    stats = @listener.statistics if @listener
    raise "First call MessageConsumer::on_message with :statistics=>true before calling MessageConsumer::statistics()" unless stats
    stats
  end

end
