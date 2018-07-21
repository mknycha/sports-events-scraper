# frozen_string_literal: true

class WebScraper
  TIME_INDEX = 0
  SCORE_INDEX = 1
  SOCCER_SCORES_PATH = "http://sports.williamhill.com/bet/en-gb/betlive/9"

  def initialize(logger)
    @events_hash = {}
    @logger = logger
  end

  def run
    begin
      print_and_pass_to_logger '### Started checking events ###'
      setup_driver
      setup_events_table
      set_driver_timeout
      visit_page
      tables = get_tables
      tables.each do |table|
        process_table(table)
      end
      print_and_pass_to_logger '### Finished checking events ###'
      send_events_table
    ensure
      @driver.quit unless @driver.nil?
    end
  end

  private

  def setup_driver
    caps = Selenium::WebDriver::Remote::Capabilities.chrome(
      "chromeOptions" => {"args" => [ "disable-infobars", "headless" ]}
    )
    @driver = Selenium::WebDriver.for :remote, url: 'http://localhost:4444/wd/hub', desired_capabilities: caps
  end

  def set_driver_timeout
    @driver.manage.timeouts.implicit_wait = 10
  end

  def visit_page
    @driver.navigate.to SOCCER_SCORES_PATH
  end

  def process_table(table)
    live_event_rows = get_live_event_rows_from_table(table)
    live_event_rows.each do |live_event_row|
      name, time, score, link = get_event_data_from_row(live_event_row)
      next if event_time_format_is_invalid(time) || time.nil?
      event_id = get_id_from_link(link)
      if hash_contains_event?(event_id)
        event = get_event_from_hash(event_id)
        event.update_time_and_score(time, score) unless event.reported
      else
        event = Event.new(name, time, score, link)
        save_event_to_hash(event_id, event)
      end
      if event.should_be_reported? && !event.reported
        event.mark_as_reported
        add_to_events_table(event)
        puts "Found an event ID:#{event_id} Name:#{event.name}"
      end
    end
  end

  def setup_events_table
    @events_html_table = EventsHtmlTable.new
  end

  def get_tables
    sport_9_types = @driver.find_element(id: 'ip_sport_9_types')
    sport_9_types.find_elements(class: 'tableData')
  end

  def get_live_event_rows_from_table(table_element)
    table_element.find_elements(class: 'rowLive')
  end

  def get_event_data_from_row(row_element)
    href_element = row_element.find_element(xpath: './/td/a[@href]')
    name = href_element.text
    link = href_element.attribute('href')
    table_score_elements = row_element.find_elements(class: 'Score')
    time = table_score_elements[TIME_INDEX]&.text
    score = table_score_elements[SCORE_INDEX]&.text
    [name, time, score, link]
  end

  def event_time_format_is_invalid(event_time)
    time_formatted = event_time[/\d{2}:\d{2}/]
    time_formatted.nil?
  end

  def get_id_from_link(link)
    link.split('/')[-2]
  end

  def hash_contains_event?(event_id)
    @events_hash.has_key?(event_id)
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

  def send_events_table
    return  if @events_html_table.empty?
    print_and_pass_to_logger 'Sending email...'
    ::Mailer.send_table_by_email(@events_html_table.to_s)
    print_and_pass_to_logger 'Email sent!'
  end

  def print_and_pass_to_logger(message)
    puts message
    @logger.info(message)
  end
end
