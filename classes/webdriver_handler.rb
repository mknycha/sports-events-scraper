# frozen_string_literal: true

class WebdriverHandler
  TIME_INDEX = 0
  SCORE_INDEX = 1
  SOCCER_SCORES_PATH = "http://sports.williamhill.com/bet/en-gb/betlive/9"

  def initialize
    setup_driver
    set_driver_timeout
  end

  def get_live_events_data
    visit_page
    results = []
    get_tables.each do |table|
      live_event_rows = get_live_event_rows_from_table(table)
      live_event_rows.each do |row_element|
        results << get_event_data_from_row(row_element)
      end
    end
    results
  end

  def link_to_event_stats_page(event_link)
    @driver.navigate.to event_link
    while scoreboard_frame_doesnt_exist?
      @driver.navigate.refresh
    end
    iframe_element = @driver.find_element(id: 'scoreboard_frame').find_element(tag_name: 'iframe')
    iframe_element.property('src')
  end

  def get_event_stats(detailed_page_link)
    @driver.navigate.to detailed_page_link
    general_stats_wrapper = @driver.find_element(id: 'stats_wrapper')
    stat_wrappers = general_stats_wrapper.find_elements(class: 'stat-wrapper')
    stat_wrappers.each_with_object({}) do |el, result|
      key = el.find_element(class: 'img').attribute('class').split(' _').last.to_sym
      value = {
        home: el.find_element(class: 'home').text.to_i,
        away: el.find_element(class: 'away').text.to_i
      }
      result[key] = value
    end
  end

  def quit_driver
    @driver&.quit
  end

  private

  def setup_driver
    caps = Selenium::WebDriver::Remote::Capabilities.chrome(
      'chromeOptions' => {'args' => [ 'disable-infobars', 'headless' ]}
    )
    @driver = Selenium::WebDriver.for :remote, url: 'http://localhost:4444/wd/hub', desired_capabilities: caps
  end

  def set_driver_timeout
    @driver.manage.timeouts.implicit_wait = 30
  end

  def visit_page
    @driver.navigate.to SOCCER_SCORES_PATH
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

  def scoreboard_frame_doesnt_exist?
    !@driver.page_source.include? 'scoreboard_frame'
  end
end
