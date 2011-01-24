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

# Extend JMS Message Interface with Ruby methods
#
# A Message is the item that can be put on a queue, or obtained from a queue.
# 
# A Message consists of 3 major parts:
#   - Header
#     Accessible as attributes of the Message class
#   - Properties
#     Accessible via [] and []= methods
#   - Data
#     The actual data portion of the message
#     See the specific message types for details on how to access the data
#     portion of the message
#
# For further help on javax.jms.Message
#   http://download.oracle.com/javaee/6/api/index.html?javax/jms/Message.html
#
# Interface javax.jms.Message
module javax.jms::Message

  # Methods directly exposed from the Java class:
  
  # call-seq:
  #   acknowledge
  #
  # Acknowledges all consumed messages of the session of this consumed message
  #

  # call-seq:
  #   clear_body
  #
  #  Clears out the message body
  #

  # call-seq:
  #   clear_properties
  #
  #  Clears out the properties of this message
  #
  
  # Header Fields - Attributes of the message
  
  # Return the JMS Delivery Mode as a symbol
  #   :peristent
  #   :non_peristent
  #   other: Value from javax.jms.DeliveryMode
  def jms_delivery_mode
    case getJMSDeliveryMode
    when javax.jms.DeliveryMode::PERSISTENT
      :peristent
    when javax.jms.DeliveryMode::NON_PERSISTENT
      :non_peristent
    else
      getJMSDeliveryMode
    end
  end
  
  # Set the JMS Delivery Mode
  # Valid values for mode
  #   :peristent
  #   :non_peristent
  #   other: Any constant from javax.jms.DeliveryMode
  def jms_delivery_mode=(mode)
    val = case mode
    when :peristent
      javax.jms.DeliveryMode::PERSISTENT
    when :non_peristent
      javax.jms.DeliveryMode::NON_PERSISTENT
    else
      mode
    end
    self.setJMSDeliveryMode(val)
  end
  
  # Is the message persistent?
  def persistent?
    getJMSDeliveryMode == javax.jms.DeliveryMode::PERSISTENT
  end
  
  # Returns the Message correlation ID as a String
  # The resulting string may contain nulls
  def jms_correlation_id
    String.from_java_bytes(getJMSCorrelationIDAsBytes) if getJMSCorrelationIDAsBytes
  end
  
  # Set the Message correlation ID
  #   correlation_id: String
  # Also supports embedded nulls within the correlation id
  def jms_correlation_id=(correlation_id)
    setJMSCorrelationIDAsBytes(correlation_id.nil? ? nil : correlation_id.to_java_bytes)
  end
  
  # Returns the Message Destination
  #  Instance of javax.jms.Destination
  def jms_destination
    getJMSDestination
  end
  
  # Set the Message Destination
  #   jms_destination: Must be an instance of javax.jms.Destination
  def jms_destination=(destination)
    setJMSDestination(destination)
  end
  
  # Return the message expiration value as an Integer
  def jms_expiration
    getJMSExpiration
  end
  
  # Set the Message expiration value
  #   expiration: Integer
  def jms_expiration=(expiration)
    setJMSExpiration(expiration)
  end
  
  # Returns the Message ID as a String
  # The resulting string may contain embedded nulls
  def jms_message_id
    getJMSMessageID
  end
  
  # Set the Message correlation ID
  #   message_id: String
  # Also supports nulls within the message id
  def jms_message_id=(message_id)
    setJMSMessageID(message_id)
  end
  
  # Returns the Message Priority level as an Integer
  def jms_priority
    getJMSPriority
  end
  
  # Set the Message priority level
  #   priority: Integer
  def jms_priority=(priority)
    setJMSPriority(priority)
  end
  
  # Indicates whether the Message was redelivered?
  def jms_redelivered?
    getJMSRedelivered
  end
  
  # Set whether the Message was redelivered
  #   bool: Boolean
  def jms_redelivered=(bool)
    setJMSPriority(bool)
  end
  
  # Returns the Message reply to Destination
  #  Instance of javax.jms.Destination
  def jms_reply_to
    getJMSReplyTo
  end
  
  # Set the Message reply to Destination
  #   reply_to: Must be an instance of javax.jms.Destination
  def jms_reply_to=(reply_to)
    setJMSReplyTo(reply_to)
  end
  
  # Returns the Message timestamp as Java Timestamp Integer
  #TODO Return Ruby Time object? 
  def jms_timestamp
    getJMSTimestamp
  end
  
  # Set the Message reply to Destination
  #   timestamp: Must be an Java Timestamp Integer
  #TODO Support Ruby Time
  def jms_timestamp=(timestamp)
    setJMSTimestamp(timestamp)
  end
  
  # Returns the Message type supplied by the client when the message was sent
  def jms_type
    getJMSType
  end
  
  # Sets the Message type
  #   type: String
  def jms_type=(type)
    setJMSType(type)
  end
  
  # Return the attributes (header fields) of the message as a Hash
  def attributes
    {
      :jms_correlation_id => jms_correlation_id,
      :jms_delivery_mode => jms_delivery_mode,
      :jms_destination => jms_destination,
      :jms_expiration => jms_expiration,
      :jms_message_id => jms_message_id,
      :jms_priority => jms_priority,
      :jms_redelivered => jms_redelivered?,
      :jms_reply_to => jms_reply_to,
      :jms_timestamp => jms_timestamp,
      :jms_type => jms_type,
    }
  end

  # Methods for manipulating the message properties

  # Get the value of a property
  def [](key)
    getObjectProperty key.to_s
  end

  # Set a property
  def []=(key, value)
    setObjectProperty(key.to_s, value)
  end

  # Does message include specified property?
  def include?(key)
    # Ensure a Ruby true is returned
    property_exists key == true
  end

  # Return Properties as a hash
  def properties
    h = {}
    properties_each_pair {|k,v| h[k]=v}
    h
  end

  # Set Properties from an existing hash
  def properties=(h)
    clear_properties
    h.each_pair {|k,v| setObjectProperty(k.to_s, v)}
    h
  end

  # Return each name value pair
  def properties_each_pair(&proc)
    enum = getPropertyNames
    while enum.has_more_elements
      key = enum.next_element
      proc.call key, getObjectProperty(key)
    end
  end

  def inspect
    "#{self.class.name}: #{data}\nAttributes: #{attributes.inspect}\nProperties: #{properties.inspect}"
  end
  
end