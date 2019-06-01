# frozen_string_literal: true

class DoubleLogger < Logger
  def initialize
    # rubocop:disable Lint/UselessAssignment
    @file_logger = Logger.new('logs/logfile.log', shift_age = 0, shift_size = 10_000_000)
    # rubocop:enable Lint/UselessAssignment
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
