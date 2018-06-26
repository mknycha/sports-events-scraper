require 'selenium-webdriver'
require 'pry'
require_relative 'settings'

# WebScraper is supposed to create/update bet data objects and check if these are interesting.
# If they are, should report them to the user and mark them as reported
# How to store bet data objects, so they can be checked later?
# Maybe it would good to parse event id (from the link?) and created a hash, where event data would be stored under event_id

class EventData
  def intialize(name, time, score, link)
    @name = name
    @time = time
    @score = score
    @link = link
    @reported = false
  end

  def mark_as_reported
    @reported = true
  end

  def should_be_reported?

  end
end

class WebScraper
  TIME_INDEX = 0
  SCORE_INDEX = 1
  SOCCER_SCORES_PATH = "http://sports.williamhill.com/bet/en-gb/betlive/9"

  def run
    begin
      setup_driver
      @driver.navigate.to SOCCER_SCORES_PATH
      tables = get_tables
      tables.each do |table|
        name, time, score, link = get_event_data_from_table(table)
        time_formatted = time[/\d{2}:\d{2}/]
        next if time_formatted.nil?
        id = get_id_from_link(link)
        puts "TIME: #{time} SCORE: #{score} ID: #{id}"
      end
    ensure
      @driver.quit unless @driver.nil?
    end
  end

  private

  def setup_driver
    caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {"args" => [ "disable-infobars" ]})
    @driver = Selenium::WebDriver.for :remote, url: 'http://localhost:4444/wd/hub', desired_capabilities: caps
  end

  def get_event_data_from_table(source_table)
    href_element = source_table.find_element(xpath: './/td/a[@href]')
    name = href_element.text
    link = href_element.attribute('href')
    table_score_elements = source_table.find_elements(class: 'Score')
    time = table_score_elements[TIME_INDEX]&.text
    score = table_score_elements[SCORE_INDEX]&.text
    [name, time, score, link]
  end

  def get_tables
    sport_9_types = @driver.find_element(id: 'ip_sport_9_types')
    sport_9_types.find_elements(class: 'tableData')
  end

  def get_id_from_link(link)
    link.split('/')[-2]
  end
end

WebScraper.new.run
