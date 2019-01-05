# frozen_string_literal: true

class WebScraper
  def initialize(logger)
    @events_hash = {}
    @logger = logger
  end

  def run
    setup_events_table
    setup_webdriver_handler
    print_and_pass_to_logger 'Checking events'
    live_events_data = @webdriver_handler.get_live_events_data
    print_and_pass_to_logger 'Finished checking events'
    print_and_pass_to_logger 'Processing events data'
    live_events_data.each do |event_data_array|
      name, time, score, link = event_data_array
      next if event_time_format_is_invalid(time) || time.nil? || score.nil?
      process_event(name, time, score, link)
    end
    print_and_pass_to_logger 'Finished processing events data'
    send_events_table_and_log_info unless @events_html_table.empty?
  rescue ::Selenium::WebDriver::Error::NoSuchElementError => error
    handle_no_such_element_error(error)
  ensure
    @webdriver_handler.quit_driver
  end

  private

  def setup_events_table
    @events_html_table = EventsHtmlTable.new
  end

  def setup_webdriver_handler
    @webdriver_handler = WebdriverHandler.new
  end

  def process_event(name, time, score, link)
    event_id = get_id_from_link(link)
    if hash_contains_event?(event_id)
      event = get_event_from_hash(event_id)
      unless event.reported
        event.update_time_and_score(time, score)
        @logger.info "Temp storage: updated event\n#{event}"
      end
    else
      event = Event.new(name, time, score, link)
      save_event_to_hash(event_id, event)
      @logger.info "Temp storage: added event\n#{event}"
    end
    return unless event.time_and_score_reportable? && !event.reported

    @logger.info "Checking details for event: \n#{event}"
    unless event.link_to_stats
      event.link_to_stats = @webdriver_handler.link_to_event_stats_page(
        event.link
      )
    end
    stats = @webdriver_handler.get_event_stats(event.link_to_stats)
    event.update_details_from_scraped_attrs(stats)
    return unless event.details_reportable?

    event.mark_as_reported
    add_to_events_table(event)
    @logger.info "Table for sending: added event\n#{event}"
    puts "Found an event ID:#{event_id} Name:#{event.name}"
  end

  def event_time_format_is_invalid(event_time)
    time_formatted = event_time[/\d{2}:\d{2}/]
    time_formatted.nil?
  end

  def get_id_from_link(link)
    link.split('/')[-2]
  end

  def hash_contains_event?(event_id)
    @events_hash.key?(event_id)
  end

  def get_event_from_hash(event_id)
    @events_hash[event_id]
  end

  def save_event_to_hash(event_id, event)
    @events_hash[event_id] = event
  end

  def add_to_events_table(event)
    @events_html_table.add_event(event)
  end

  def send_events_table_and_log_info
    print_and_pass_to_logger 'Sending email'
    ::Mailer.send_table_by_email(@events_html_table.to_s)
    print_and_pass_to_logger 'Email sent!'
  end

  def print_and_pass_to_logger(message)
    puts message
    @logger.info(message)
  end

  def handle_no_such_element_error(error)
    @logger.warn error.message
    puts 'Table with live events or its children not found - see logs for details'
  end
end
