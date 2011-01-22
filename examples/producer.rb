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

#
# Sample Producer:
#          Write messages to the queue
#

# Allow examples to be run in-place without requiring a gem install
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'jms'
count = (ARGV[0] || 1).to_i
 
JMS::Connection.create_session(
  :jndi_name => '/ConnectionFactory',
  :jndi_context => {
    'java.naming.factory.initial' => 'org.jnp.interfaces.NamingContextFactory',
    'java.naming.provider.url' => 'jnp://﻿localhost:1099',
    'java.naming.factory.url.pkgs' => 'org.jboss.naming:org.jnp.interfaces',
    'java.naming.security.principal' => 'guest',
    'java.naming.security.credentials' => 'guest'
  }
) do |session|
  start_time = Time.now
  
  session.producer(:q_name => 'ExampleQueue') do |producer|
    count.times do |i| 
      msg = session.message("Hello Producer #{i}")
      msg.jmsdelivery_mode = Java::javax.jms.DeliveryMode::NON_PERSISTENT
      producer.send msg
    end
  end

  duration = Time.now - start_time
  puts "Delivered #{count} messages in #{duration} seconds at #{count/duration} messages per second"
end
