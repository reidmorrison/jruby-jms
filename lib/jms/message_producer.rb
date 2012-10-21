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

# Extend JMS Message Producer Interface with Ruby methods
#
# For further help on javax.jms.MessageProducer
#   http://download.oracle.com/javaee/6/api/javax/jms/MessageProducer.html
#
# Interface javax.jms.Producer
module JMS::MessageProducer

  # Return the Delivery Mode as a Ruby symbol
  #   :persistent
  #   :non_persistent
  #   nil if unknown
  def delivery_mode_sym
    case delivery_mode
    when JMS::DeliveryMode::PERSISTENT
      :persistent
    when JMS::DeliveryMode::NON_PERSISTENT
      :non_persistent
    else
      nil
    end
  end

  # Set the JMS Delivery Mode from a Ruby Symbol
  # Valid values for mode
  #   :persistent
  #   :non_persistent
  #
  # Example:
  #   producer.delivery_mode_sym = :persistent
  def delivery_mode_sym=(mode)
    val = case mode
    when :persistent
      JMS::DeliveryMode::PERSISTENT
    when :non_persistent
      JMS::DeliveryMode::NON_PERSISTENT
    else
      raise "Unknown delivery mode symbol: #{mode}"
    end
    self.delivery_mode = val
  end

end
