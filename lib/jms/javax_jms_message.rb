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
#Interface javax.jms.Message
#
# A Message is the item that can be put on a queue, or obtained from a queue.
# A Message consists of 3 major parts:
#   - Header
#   - Properties
#   - Data
#
# The Header can contain one or more header items that are often linked together
#     :jms_message_id
#     :jms_correlation_id
#     :jms_type
#     :jms_delivery_mode
#     :jms_expiration
#     :jms_priority
#     :jms_redelivered
#     :jms_reply_to
#     :jms_timestamp
#     
#  The following attributes are accessible in the message:
#    jmscorrelation_id
#    jmscorrelation_idas_bytes
#    jmsdelivery_mode
#    jmsdestination
#    jmsexpiration
#    jmsmessage_id
#    jmspriority
#    jmsredelivered
#    jmsredelivered?
#    jmsreply_to
#    jmstimestamp
#    jmstype
#
# The Properties are JMS Properties of the message itself, such as:
#
# The Data is the actual payload or raw data being sent or received
#
module Java::javaxJms::Message

  # Properties Methods

  # Get the value of a property
  def get_property(key)
    getObjectProperty key.to_s
  end

  # Set a property
  def set_property(key, value)
    setObjectProperty(key.to_s, value)
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

  # Does message include specified property?
  def include_property?(key)
    # Ensure a Ruby true is returned
    property_exists key == true
  end

  # JMS Getter and setters since JRuby does not detect them correctly
  #alias jms_correlation_id getJMSCorrelationID
  #alias jms_correlation_id= setJMSCorrelationID

  # Header Fields

  # Set Header fields from those in a hash
  def header=(h)
    h.each do |key,val|
      case key.to_sym
      when :jms_correlation_id
        self.jMSCorrelationID = val
      when :jms_delivery_mode
        self.jMSDeliveryMode = case val
        when :peristent
          Java::javax.jms.DeliveryMode::PERSISTENT
        when :non_peristent
          Java::javax.jms.DeliveryMode::NON_PERSISTENT
        else
          val
        end
      when :jms_destination
        # Not possible from string, has to be a Destination Object that we cannot create here :(
        self.jMSDestination = val
      when :jms_expiration
        self.jMSExpiration = val
      when :jms_message_id
        self.jMSMessageID = val
      when :jms_priority
        self.jMSPriority = val
      when :jms_redelivered
        self.jMSRedelivered = val
      when :jms_reply_to
        # Not possible from string, has to be a Destination Object that we cannot create here :(
        self.jMSReplyTo = val
      when :jms_timestamp
        self.jMSTimestamp = val
      when :jms_type
        self.jMSType = val
      else
        raise "Invalid Descriptor key:#{key} supplied to Message::descriptor="
      end
    end
  end

  # Extract Header fields as a Hash from JMS Message
  def header
    delivery_mode = case jMSDeliveryMode
    when Java::javax.jms.DeliveryMode::PERSISTENT
      :peristent
    when Java::javax.jms.DeliveryMode::NON_PERSISTENT
      :non_peristent
    else
      nil
    end

    {
      :jms_correlation_id => jMSCorrelationID,
      :jms_delivery_mode => delivery_mode,
      :jms_destination => jMSDestination,
      :jms_expiration => jMSExpiration,
      :jms_message_id => jMSMessageID,
      :jms_priority => jMSPriority,
      :jms_redelivered => jMSRedelivered,
      :jms_reply_to => jMSReplyTo,
      :jms_timestamp => jMSTimestamp,
      :jms_type => jMSType,
    }
  end

  def inspect
    "#{self.class.name}: #{data}\nHeader: #{header.inspect}\nProperties: #{properties.inspect}"
  end
end