# frozen_string_literal: true

class WebScraper
  TIME_INDEX = 0
  SCORE_INDEX = 1
  SOCCER_SCORES_PATH = "http://sports.williamhill.com/bet/en-gb/betlive/9"

  def initialize
    @events_hash = {}
  end

  def run
    begin
      puts '### Started checking events ###'
      setup_driver
      @driver.navigate.to SOCCER_SCORES_PATH
      tables = get_tables
      tables.each do |table|
        live_event_rows = get_live_event_rows_from_table(table)
        live_event_rows.each do |live_event_row|
          name, time, score, link = get_event_data_from_row(live_event_row)
          next if event_time_format_is_invalid(time)
          event_id = get_id_from_link(link)
          if event_exists?(event_id)
            event = get_event_from_hash(event_id)
            next if event.reported
            event.time = time
            event.score = score
          else
            event = Event.new(name, time, score, link)
            save_event_to_hash(event_id, event)
          end
          if event.should_be_reported?
            event.mark_as_reported
            puts event
          end
        end
      end
      puts '### Finished checking events ###'
    ensure
      @driver.quit unless @driver.nil?
    end
  end

  private

  def setup_driver
    caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {"args" => [ "disable-infobars" ]})
    @driver = Selenium::WebDriver.for :remote, url: 'http://localhost:4444/wd/hub', desired_capabilities: caps
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

  def event_exists?(event_id)
    @events_hash.has_key?(event_id)
  end

  def get_event_from_hash(event_id)
    @events_hash[event_id]
  end

  def save_event_to_hash(event_id, event)
    @events_hash[event_id] = event
  end
end
