jruby-jms
=========

* http://github.com/reidmorrison/jruby-jms

### Current Activities & Backward Compatibility

Please read the source files for now for documentation. Looking into rdoc doc
generation issue.

There may still be some changes to the API to make things better and/or simpler.

Once the code goes to V1.0.0 I will make every effort to not break the 
existing interface in any way.

### Feedback is welcome and appreciated :)

### Todo

* Need to get rdoc working
* More tests, especially pub/sub

### Introduction

jruby-jms has been around in my toolbox since 2008. Since I was not an expert
in JMS I have held off releasing to the wild. I believe it is now of sufficient 
quality and usefulness to release into the wild. In fact it has been used
in production at an enterprise site for 2 years now.

jruby-jms attempts to "rubify" the Java JMS API without 
compromising performance. It does this by sprinkling "Ruby-goodness" into the
existing JMS Java interfaces, I.e. By adding Ruby methods to the existing 
classes and interfaces. Since jruby-jms exposes the JMS
Java classes directly there is no performance impact that would have been
introduced had the entire API been wrapped in a Ruby layer.

In this way, using regular Ruby constructs a Ruby program can easily
interact with JMS in a highly performant way. Also, in this way you are not
limited to whatever the Ruby wrapper would have exposed, since the entire JMS
API is available to you at any time.

### Install

    gem install jruby-jms

### Simplification

One of the difficulties with the regular JMS API is that it use completely
separate classes for Topics and Queues in JMS 1.1. This means that once a 
program writes to a Queue for example, that without changing the program it
could not be changed to write to a topic. Also a consumer on a topic or a queue
are identical. jruby-jms fixes this issue by allowing you to have a Consumer
or Producer that is independent of whether it is producing or consuming to/from
or a Topic or a Queue. The complexity of which JMS class is used is taken care
of by jruby-jms.

Concepts & Terminology
----------------------

### Java Message Service (JMS) API

The JMS API is a standard interface part of Java EE 6 as a way for programs to
send and receive messages through a messaging and queuing system.

For more information on the JMS API: http://download.oracle.com/javaee/6/api/index.html?javax/jms/package-summary.html

### Broker / Queue Manager

Depending on which JMS provider you are using they refer to their centralized
server as either a Broker or Queue Manager. The Broker or Queue Manager is the
centralized "server" through which all messages pass through.

Some Brokers support an in-vm broker instance so that messages can be passed
between producers and consumers within the same Java Virtual Machine (JVM) 
instance. This removes the need to make any network calls. Highly recommended
for passing messages between threads in the same JVM.

### Connection

In order to connect to any broker the Client JMS application must create a
connection. In traditional JMS a ConnectionFactory is used to create connections.
In jruby-jms the JMS::Connection takes care of the complexities of dealing with
the factory class, just pass the required parameters to Connection.new at it
takes care of the rest.

### Queue

A queue used for holding messages. 
The queue is defined prior to the message being sent and is used to hold the
messages. The consumer does not have to be running in order to receive messages.

### Topic

Instead of sending messages to a single queue, a topic can be used to publish
messages and allow multiple consumers to register for messages that match the
topic they are interested in

### Producer

Producers write message to a queue or topic

ActiveMQ Example:
    require 'rubygems'
    
    # Include JMS after ActiveMQ
    require 'jms'
    
    # Connect to ActiveMQ
    config = {
      :factory => 'org.apache.activemq.ActiveMQConnectionFactory',
      :broker_url => 'tcp://localhost:61616',
      :require_jars => ["~/Applications/apache-activemq-5.4.2/activemq-all-5.4.2.jar"]
    }

    JMS::Connection.session(config) do |session|
      session.producer(:q_name => 'ExampleQueue') do |producer|
        producer.send(session.message("Hello World"))
      end
    end

### Consumer

Consumers read message from a queue or topic

ActiveMQ Example:
    require 'rubygems'
    
    # Include JMS after ActiveMQ
    require 'jms'
    
    # Connect to ActiveMQ
    config = {
      :factory => 'org.apache.activemq.ActiveMQConnectionFactory',
      :broker_url => 'tcp://localhost:61616',
      :require_jars => ["~/Applications/apache-activemq-5.4.2/activemq-all-5.4.2.jar"]
    }
    
    JMS::Connection.session(config) do |session|
      session.consume(:q_name => 'ExampleQueue', :timeout=>1000) do |message|
        p message
      end
    end

Overview
--------

jruby-jms is a complete JRuby API into the Java Messaging Specification (JMS) 
followed by many JMS Providers.

In order to communicate with a JMS provider jruby-jms needs the jar files in the
CLASSPATH that are supplied by the JMS Provider.

Threading
---------

A JMS::Connection instance can be shared between threads, whereas a session, 
consumer, producer, and any artifacts created by the session should only be 
used by one thread at a time.

For consumers, it is recommended to create a session for each thread and leave
that thread blocked on Consumer.receive. Or, even better use Connection.on_message
which will create a session, within which any message received from the specified
queue or topic match will be passed to the block.

### Example

Logging
-------

jruby-jms detects the logging available in the current environment.
When running under Rails it will use the Rails logger, otherwise the standard
Ruby logger. The logger can also be replaced by calling Connection.logger=

Dependencies
------------

### JRuby

jruby-jms has been tested against JRuby 1.5.1 and 1.6, but should work with any
current JRuby version.

### JMS

Every JMS Provider has details on which jar files to include in your CLASSPATH
for their JMS client to work. Some examples for connection settings are covered
in the Connection.new documentation

Development
-----------

Want to contribute to jruby-jms?

First clone the repo and run the tests:

    git clone git://github.com/reidmorrison/jruby-jms.git
    cd jruby-jms
    jruby -S rake test

Feel free to ping the mailing list with any issues and we'll try to resolve it.


Contributing
------------

Once you've made your great commits:

1. [Fork][1] jruby-jms
2. Create a topic branch - `git checkout -b my_branch`
3. Push to your branch - `git push origin my_branch`
4. Create an [Issue][2] with a link to your branch
5. That's it!

You might want to checkout our [Contributing][cb] wiki page for information
on coding standards, new features, etc.


Mailing List
------------

TBA

Meta
----

* Code: `git clone git://github.com/reidmorrison/jruby-jms.git`
* Home: <http://github.com/reidmorrison/jruby-jms>
* Docs: <http://jruby-jms.github.com/jruby-jms/>
* Bugs: <http://github.com/reidmorrison/jruby-jms/issues>
* List: TBA
* Gems: <http://gemcutter.org/gems/jruby-jms>

This project uses [Semantic Versioning][sv].


Author
------

Reid Morrison :: rubywmq@gmail.com :: @reidmorrison

[1]: http://help.github.com/forking/
[2]: http://github.com/reidmorrison/jruby-jms/issues
[sv]: http://semver.org/

License
-------

Copyright 2008 - 2011  J. Reid Morrison

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
