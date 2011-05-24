# Workaround for IBM MQ JMS implementation that implements some undocumented methods

begin
  
  class com.ibm.mq.jms::MQQueueSession    
    def consume(params, &proc)
      Java::JavaxJms::Session.instance_method(:consume).bind(self).call(params, &proc)
    end
  end

  class com.ibm.mq.jms::MQSession    
    def consume(params, &proc)
      Java::JavaxJms::Session.instance_method(:consume).bind(self).call(params, &proc)
    end
  end
  
  class com.ibm.mq.jms::MQQueueBrowser
    def each(params, &proc)
      Java::ComIbmMsgClientJms::JmsQueueBrowser.instance_method(:each).bind(self).call(params, &proc)
    end
  end

  class com.ibm.mq.jms::MQQueueReceiver
    def each(params, &proc)
      Java::JavaxJms::MessageConsumer.instance_method(:each).bind(self).call(params, &proc)
    end
    def get(params={})
      Java::JavaxJms::MessageConsumer.instance_method(:get).bind(self).call(params)
    end
  end
  
  class com.ibm.mq.jms::MQQueue
    undef_method :delete
  end

rescue NameError
  # Ignore errors (when we aren't using MQ)
end
