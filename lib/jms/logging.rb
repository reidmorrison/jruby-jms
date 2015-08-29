# Add Logging capabilities
module JMS

  # Returns the logger being used by jruby-jms
  # Unless previously set, it will try to use the Rails logger and if it
  # is not present, it will return a new Ruby logger
  def self.logger
    @logger ||= (self.rails_logger || self.ruby_logger)
  end

  # Replace the logger for jruby-jms
  def self.logger=(logger)
    @logger = logger
  end

  # Use the ruby logger, but add needed trace level logging which will result
  # in debug log entries
  def self.ruby_logger(level=nil, target=STDOUT)
    require 'logger'

    l = ::Logger.new(target)
    l.instance_eval 'alias :trace :debug'
    l.instance_eval 'alias :trace? :debug?'
    l.level = level || ::Logger::INFO
    l
  end

  private
  def self.rails_logger
    (defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger) ||
      (defined?(RAILS_DEFAULT_LOGGER) && RAILS_DEFAULT_LOGGER.respond_to?(:debug) && RAILS_DEFAULT_LOGGER)
  end

end
