# Workaround for IBM MQ JMS implementation that implements some undocumented methods

begin
  
  class com.ibm.mq.jms::MQQueueSession
    
    if self.instance_methods.include? "consume"
      def consume(params, &proc)
        Java::JavaxJms::Session.instance_method(:consume).bind(self).call(params, &proc)
      end
    end

  end


  class com.ibm.mq.jms::MQSession

    if self.instance_methods.include? "consume"
      def consume(params, &proc)
        Java::JavaxJms::Session.instance_method(:consume).bind(self).call(params, &proc)
      end
    end
    
    if self.instance_methods.include? "create_destination"
      def create_destination(params)
        Java::JavaxJms::Session.instance_method(:create_destination).bind(self).call(params)
      end
    end

  end

  
  class com.ibm.mq.jms::MQQueueBrowser

    if self.instance_methods.include? "each"
      def each(params, &proc)
        Java::ComIbmMsgClientJms::JmsQueueBrowser.instance_method(:each).bind(self).call(params, &proc)
      end
    end
  end
  

  class com.ibm.mq.jms::MQQueueReceiver
    
    if self.instance_methods.include? "each"
      def each(params, &proc)
        Java::JavaxJms::MessageConsumer.instance_method(:each).bind(self).call(params, &proc)
      end
    end
    
    if self.instance_methods.include? "get"
      def get(params={})
        Java::JavaxJms::MessageConsumer.instance_method(:get).bind(self).call(params)
      end
    end
    
  end
  
  
  class com.ibm.mq.jms::MQQueue
    
    if self.instance_methods.include? "delete"
    undef_method :delete
    end
    
  end

rescue NameError
  # Ignore errors (when we aren't using MQ)
end
