# frozen_string_literal: true

class ResultCheckerWorker
  @queue = :general

  def self.perform(event_id, name, time, score, link)
    updated_event = Event.new(name, time, score, link) # TODO: Isn't score the only needed thing here?
    reported_event = ReportedEvent.find_by(event_id: event_id)
    event_details = webdriver_handler.find_event_details(reported_event.event_id)
    flag = EventResultsPredictionUpdater.losing_team_scored_next(reported_event,
                                                                 updated_event,
                                                                 event_details.nil?)
    return if flag.nil?

    reported_event.losing_team_scored_next = flag
    reported_event.save
    logger.info 'Updated prediction result for an event: ' \
                  "\n#{reported_event}\nLosing team scored next?: #{flag}"
  rescue StandardError => err
    logger.error err.message
    err.backtrace.each { |line| logger.error line }
  ensure
    webdriver_handler.quit_driver
  end

  def self.logger
    @logger ||= DoubleLogger.new('result_checker_worker')
  end

  def self.webdriver_handler
    @webdriver_handler ||= WebdriverHandler.new(logger)
  end

  private_class_method :logger, :webdriver_handler
end