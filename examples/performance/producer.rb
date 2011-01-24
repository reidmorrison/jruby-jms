#
# Sample Producer:
#   Write messages to the queue
#

# Allow examples to be run in-place without requiring a gem install
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../../lib'

require 'rubygems'
require 'jms'
count = (ARGV[0] || 1).to_i
 
JMS::Connection.session(
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
      producer.send(session.message("Hello Producer #{i}"))
    end
  end

  duration = Time.now - start_time
  puts "Delivered #{count} messages in #{duration} seconds at #{count/duration} messages per second"
end
