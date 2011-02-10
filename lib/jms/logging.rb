# Add HornetQ logging capabilities
module JMS
  
  # Returns the logger being used by jruby-jms
  def self.logger
    @logger ||= (rails_logger || default_logger)
  end

  # Replace the logger for jruby-jms
  def self.logger=(logger)
    @logger = logger
  end

  private
  def self.rails_logger
    (defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger) ||
      (defined?(RAILS_DEFAULT_LOGGER) && RAILS_DEFAULT_LOGGER.respond_to?(:debug) && RAILS_DEFAULT_LOGGER)
  end

  # By default we use the standard Ruby Logger
  def self.default_logger
    require 'logger'
    require 'jms/logger'
    l = Logger.new(STDOUT)
    l.level = Logger::INFO
    l
  end

end
