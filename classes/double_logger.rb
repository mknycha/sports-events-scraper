# frozen_string_literal: true

class DoubleLogger < Logger
  def initialize(logfile_name)
    @file_logger = Logger.new("logs/#{logfile_name}.log", 'daily')
    @stdout_logger = Logger.new(STDOUT)
  end

  %w[warn info error fatal debug].each do |method_name|
    define_method(method_name) do |argument|
      @file_logger.send(method_name, argument)
      @stdout_logger.send(method_name, argument)
    end
  end

  def close
    @file_logger.close
    @stdout_logger.close
  end
end
