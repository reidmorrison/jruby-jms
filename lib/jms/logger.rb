# Add trace method to Ruby Logger class
class Logger
  alias :trace :debug
end
