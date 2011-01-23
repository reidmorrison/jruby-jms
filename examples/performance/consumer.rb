#
# Sample Consumer: 
#   Retrieve all messages from a queue
#

# Allow examples to be run in-place without requiring a gem install
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../../lib'

require 'rubygems'
require 'jms'

JMS::Connection.create_session({
    :jndi_name => '/ConnectionFactory',
    :jndi_context => {
      'java.naming.factory.initial' => 'org.jnp.interfaces.NamingContextFactory',
      'java.naming.provider.url' => 'jnp://localhost:1099',
      'java.naming.factory.url.pkgs' => 'org.jboss.naming:org.jnp.interfaces',
      'java.naming.security.principal' => 'guest',
      'java.naming.security.credentials' => 'guest'
    }}
) do |session|
  session.consumer(:q_name => 'ExampleQueue') do |consumer|
    stats = consumer.each(:statistics => true) do |message|
      puts "=================================="
      p message
    end
    puts "STATISTICS :" + stats.inspect
  end
end
