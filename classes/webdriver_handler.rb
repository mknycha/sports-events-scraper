# frozen_string_literal: true

class StatsReadingError < StandardError; end

class WebdriverHandler
  TIME_INDEX = 0
  NAME_INDEX = 1
  SCORE_INDEX_A = 2
  SCORE_INDEX_B = 3

  SOCCER_SCORES_PATH = 'https://sports.williamhill.com/betting/en-gb/in-play/football'

  def initialize
    setup_driver
  end

  def find_event_ids
    visit_page
    @driver.find_elements(class: 'event').map { |event_el| event_el.attribute('id') }
  end

  def find_event_details(event_id)
    event = @driver.find_element(id: event_id)
    event_details = event.text.split("\n")
    link = event.find_element(tag_name: 'a').attribute('href')
    name = event_details[NAME_INDEX]
    time = event_details[TIME_INDEX]
    score = "#{event_details[SCORE_INDEX_A]}-#{event_details[SCORE_INDEX_B]}"
    [name, time, score, link]
  rescue Selenium::WebDriver::Error::NoSuchElementError => _e
    nil
  end

  def link_to_event_stats_page(event_link)
    @driver.navigate.to event_link
    @driver.navigate.refresh while scoreboard_frame_doesnt_exist?
    iframe_element = @driver.find_element(id: 'scoreboard_frame')
                            .find_element(tag_name: 'iframe')
    iframe_element.property('src')
  end

  def second_half_available?(detailed_page_link)
    @driver.navigate.to detailed_page_link
    second_half_tab_button = @driver.find_element(
      xpath: ".//li[@data-period='SECOND_HALF']"
    )
    Selenium::WebDriver::Wait.new(timeout: 3).until do
      !second_half_tab_button.attribute('class').include?('inactive')
    end
  rescue Selenium::WebDriver::Error::TimeoutError => _e
    false
  end

  def get_event_stats(detailed_page_link)
    @driver.navigate.to detailed_page_link
    stats_hash = all_stats_for_second_half
    stats_hash[:possession] = possession_stats_for_whole_match
    stats_hash
  end

  def quit_driver
    @driver&.quit
  end

  private

  def setup_driver
    service = Selenium::WebDriver::Service.chrome(path: ENV['DRIVER_PATH'])
    @driver = Selenium::WebDriver.for :chrome, service: service, options: driver_options
    @driver.manage.timeouts.implicit_wait = 30
  end

  def driver_options
    options = Selenium::WebDriver::Chrome::Options.new(binary: ENV['BINARY_PATH'])
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1280x1696')
    options.add_argument('--disable-application-cache')
    options.add_argument('--disable-infobars')
    options.add_argument('--no-sandbox')
    options.add_argument('--hide-scrollbars')
    options.add_argument('--enable-logging')
    options.add_argument('--log-level=0')
    options.add_argument('--single-process')
    options.add_argument('--ignore-certificate-errors')
    options.add_argument('--homedir=/tmp')
    options
  end

  def visit_page
    @driver.navigate.to SOCCER_SCORES_PATH
  end

  def scoreboard_frame_doesnt_exist?
    !@driver.page_source.include? 'scoreboard_frame'
  end

  def all_stats_for_second_half
    second_half_tab_button = @driver.find_element(
      xpath: ".//li[@data-period='SECOND_HALF']"
    )
    Selenium::WebDriver::Wait.new.until do
      !second_half_tab_button.attribute('class').include?('inactive')
    end
    second_half_tab_button.click
    stat_wrappers = general_stats_wrapper.find_elements(class: 'stat-wrapper')
    stat_wrappers.each_with_object({}) do |element, result|
      key = element.find_element(class: 'img').attribute('class').split(' _').last.to_sym
      result[key] = stat_values_home_and_away(element)
    end
  rescue Selenium::WebDriver::Error::TimeoutError => _e
    msg = 'Stats for particular event could not read, ' \
          "looks like an issue on provider's website"
    raise StatsReadingError, msg
  end

  def possession_stats_for_whole_match
    @driver.find_element(xpath: ".//li[@data-period='TOTAL']").click
    element = general_stats_wrapper.find_element(xpath: ".//div[@data-stat='possession']")
    stat_values_home_and_away(element)
  end

  def general_stats_wrapper
    @driver.find_element(id: 'stats_wrapper')
  end

  def stat_values_home_and_away(stats_element)
    {
      home: stat_number_value(stats_element, 'home'),
      away: stat_number_value(stats_element, 'away')
    }
  end

  def stat_number_value(stats_element, class_name)
    stats_element.find_element(class: class_name).text.to_i
  end
end
