# frozen_string_literal: true

class WebScraper
  VALID_TIME_FORMAT = /\A\d{2}:\d{2}\z/
  VALID_SCORE_FORMAT = /\A\d-\d\z/
  REQUEST_BLOCKED_ERROR_MSG = 'Current machine was blocked, ' \
                              'further scraping is not possible'

  def initialize(logger)
    @events_storage = EventsStorage.new(logger)
    @logger = logger
  end

  def run
    setup_events_table
    setup_webdriver_handler
    @logger.info 'Checking events on site'
    events_ids = @webdriver_handler.find_event_ids
    if events_ids.empty?
      @logger.warn 'There were no events found'
      raise ::StandardError, REQUEST_BLOCKED_ERROR_MSG if @webdriver_handler.request_blocked?
    end
    check_live_events_and_update_storage(events_ids)
    @logger.info 'Finished checking events on site'
    @logger.info 'Filtering out events where second half has not started'
    events_ids = filter_out_events_before_second_half(events_ids)
    @logger.info 'Finished filtering out events'
    @logger.info 'Saving goals stats'
    events_ids.each do |event_id|
      event = @events_storage.find_event(event_id)
      @logger.info "Scraping stats for an event:\n#{event}"
      stats = @webdriver_handler.get_event_stats(event.link_to_stats)
      event.update_details_from_scraped_attrs(stats)
      @logger.info "Event stats updated"
      event_goal = EventGoal.find_last_or_initialize(event_id: event_id)
      if event.score_home != event_goal.score_home || event.score_away != event_goal.score_away
        @logger.info "Found a goal stat for event: #{event}"
        eg = EventGoal.from_event(event)
        odds = @webdriver_handler.get_odds_for_next_team_to_score(event)
        unless odds.nil?
          eg.odds_home_to_score_next = odds[:home]
          eg.odds_away_to_score_next = odds[:away]
        end
        eg.event_id = event_id
        eg.link_to_stats = event.link_to_stats # Why does it need to assigned explicitly?
        eg.save!
      end
    end
    @logger.info 'Finished saving goals stats'
    @logger.info 'Checking results for reported events'
    ReportedEvent.where(losing_team_scored_next: nil).each do |reported_event|
      updated_event = @events_storage.find_event(reported_event.event_id)
      event_details = @webdriver_handler.find_event_details(reported_event.event_id)
      flag = EventResultsPredictionUpdater.losing_team_scored_next(reported_event,
                                                                   updated_event,
                                                                   event_details.nil?)
      next if flag.nil?

      reported_event.losing_team_scored_next = flag
      reported_event.save
      @logger.info 'Updated prediction result for an event: ' \
                   "\n#{reported_event}\nLosing team scored next?: #{flag}"
    end
    @logger.info 'Finished checking results for reported events'
    @logger.info 'Processing events data'
    events_ids.each do |event_id|
      event = @events_storage.find_event(event_id)
      save_and_report_event(event, event_id) if event.present? && event_should_be_reported?(event)
    end
    @logger.info 'Finished processing events data'
    send_events_table_and_log_info unless @events_html_table.empty?
  rescue ::Selenium::WebDriver::Error::NoSuchElementError => e
    handle_no_such_element_error(e)
  ensure
    @webdriver_handler&.quit_driver
  end

  private

  def setup_events_table
    @events_html_table = EventsHtmlTable.new
  end

  def setup_webdriver_handler
    @webdriver_handler = WebdriverHandler.new(@logger)
  end

  def check_live_events_and_update_storage(event_ids)
    event_ids.each do |event_id|
      details = @webdriver_handler.find_event_details(event_id)
      if details.nil?
        @logger.info "Event with ID \'#{event_id}\' could not be found. It may have ended"
        next
      end
      @events_storage.save_or_update_event(event_id, details)
    end
  end

  def filter_out_events_before_second_half(event_ids)
    event_ids.select do |event_id|
      event = @events_storage.find_event(event_id)
      if event.nil?
        @logger.info "Event with ID \'#{event_id}\' could not be found. It may have ended"
        false
      else
        event_second_half_started?(event, @webdriver_handler)
      end
    end
  end

  def event_second_half_started?(event, webdriver_handler)
    event.link_to_stats ||= webdriver_handler.link_to_event_stats_page(event.link)
    !event.link_to_stats.nil? && webdriver_handler.second_half_available?(event.link_to_stats)
  end

  def save_and_report_event(event, event_id)
    event.mark_as_reported
    add_to_events_table(event)
    msg_common = "\n#{event}\nDetails:\n#{event.readable_details}"
    @logger.info "Table for sending: added event:#{msg_common}"
    @logger.info "Saving event to the database: #{msg_common}"
    reported_event = ReportedEvent.from_event(event)
    reported_event.event_id = event_id
    if reported_event.save
      @logger.info 'Saved event'
    else
      @logger.warn "Event could not be saved! Errors: \n#{reported_event.errors.full_messages}"
    end
  end

  def event_should_be_reported?(event)
    event_stats_should_be_checked?(event) && event.details_reportable?
  end

  def event_stats_should_be_checked?(event)
    event.time_and_score_reportable? && !event.reported
  end

  def add_to_events_table(event)
    @events_html_table.add_event(event)
  end

  def send_events_table_and_log_info
    @logger.info 'Sending email'
    ::Mailer.send_table_by_email(@events_html_table.to_s)
    @logger.info 'Email sent!'
  end

  def handle_no_such_element_error(error)
    @logger.warn 'Table with live events or its children not found - see logs for details'
    @logger.warn error.message
  end
end
