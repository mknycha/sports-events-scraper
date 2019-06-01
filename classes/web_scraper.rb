# frozen_string_literal: true

class WebScraper
  VALID_TIME_FORMAT = /\A\d{2}:\d{2}\z/
  VALID_SCORE_FORMAT = /\A\d-\d\z/

  def initialize(logger)
    @events_storage = EventsStorage.new(logger)
    @logger = logger
  end

  def run
    setup_events_table
    setup_webdriver_handler
    @logger.info 'Checking events'
    events_ids = @webdriver_handler.find_event_ids
    check_live_events_and_update_storage(events_ids)
    @logger.info 'Finished checking events'
    @logger.info 'Processing events data'
    # Later it should iterate thorugh all unfinished events (that could be exposed through events storage)
    events_ids.each do |event_id|
      event = @events_storage.find_event(event_id)
      process_event(event) unless event.nil?
    end
    @logger.info 'Finished processing events data'
    send_events_table_and_log_info unless @events_html_table.empty?
  rescue ::Selenium::WebDriver::Error::NoSuchElementError => error
    handle_no_such_element_error(error)
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

  def process_event(event)
    return unless should_check_event_details?(event)

    event.link_to_stats ||= @webdriver_handler.link_to_event_stats_page(event.link)
    unless @webdriver_handler.second_half_available?(event.link_to_stats)
      @logger.info "Second half is not available for an event \n#{event}"
      return
    end
    @logger.info "Scraping details for an event:\n#{event}"
    stats = @webdriver_handler.get_event_stats(event.link_to_stats)
    event.update_details_from_scraped_attrs(stats)
    @logger.info "Checking details for an event:\n#{event}\nDetails:\n#{event.readable_details}"
    return unless event.details_reportable?

    event.mark_as_reported
    add_to_events_table(event)
    @logger.info "Table for sending: added event:\n#{event}\nDetails:\n#{event.readable_details}"
  end

  def should_check_event_details?(event)
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
