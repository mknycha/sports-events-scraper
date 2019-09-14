# frozen_string_literal: true

class WebScraper
  VALID_TIME_FORMAT = /\A\d{2}:\d{2}\z/
  VALID_SCORE_FORMAT = /\A\d-\d\z/
  MIN_MATCH_LENGTH_IN_MINUTES = 90
  REQUEST_BLOCKED_ERROR_MSG = 'Current machine was blocked, ' \
                              'further scraping is not possible'

  def initialize(logger)
    @events_storage = EventsStorage.new(logger)
    @logger = logger
  end

  def run
    setup_events_table
    setup_webdriver_handler
    @logger.info 'Checking events'
    events_ids = @webdriver_handler.find_event_ids
    if events_ids.empty?
      @logger.warn 'There were no events found'
      raise ::Exception, REQUEST_BLOCKED_ERROR_MSG if @webdriver_handler.request_blocked?
    end
    check_live_events_and_update_storage(events_ids)
    ReportedEvent.where(losing_team_scored_next: nil).each do |reported_event|
      updated_event = @events_storage.find_event(reported_event.event_id)
      if reported_event.created_at < MIN_MATCH_LENGTH_IN_MINUTES.minutes.ago &&
         @webdriver_handler.find_event_details(reported_event.event_id).nil?
        reported_event.losing_team_scored_next = 'no'
        reported_event.save
      elsif updated_event.nil?
        reported_event.losing_team_scored_next = 'error'
        reported_event.save
      else
        check_if_losing_team_scored_next(reported_event, updated_event)
      end
    end
    @logger.info 'Finished checking events'
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
    @webdriver_handler = WebdriverHandler.new
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

  def check_if_losing_team_scored_next(reported_event, updated_event)
    team_which_scored_next = EventConditionChecker.which_team_scored(reported_event,
                                                                     updated_event)
    if reported_event.score_home > reported_event.score_away
      losing_team = :away
      winning_team = :home
    else
      losing_team = :home
      winning_team = :away
    end
    case team_which_scored_next
    when losing_team
      reported_event.losing_team_scored_next = 'yes'
    when winning_team
      reported_event.losing_team_scored_next = 'no'
    when :both
      reported_event.losing_team_scored_next = 'error'
    end
    reported_event.save unless team_which_scored_next.nil?
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
    return false unless event_stats_should_be_checked?(event)

    event.link_to_stats ||= @webdriver_handler.link_to_event_stats_page(event.link)
    unless @webdriver_handler.second_half_available?(event.link_to_stats)
      @logger.info "Second half is not available for an event \n#{event}"
      return false
    end
    @logger.info "Scraping details for an event:\n#{event}"
    stats = @webdriver_handler.get_event_stats(event.link_to_stats)
    event.update_details_from_scraped_attrs(stats)
    @logger.info "Checking details for an event:\n#{event}\nDetails:\n#{event.readable_details}"
    return false unless event.details_reportable?

    true
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
