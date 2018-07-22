# frozen_string_literal: true

class WebdriverHandler
  TIME_INDEX = 0
  SCORE_INDEX = 1
  SOCCER_SCORES_PATH = "http://sports.williamhill.com/bet/en-gb/betlive/9"

  def get_live_events_data
    setup_driver
    set_driver_timeout
    visit_page
    results = []
    get_tables.each do |table|
      live_event_rows = get_live_event_rows_from_table(table)
      live_event_rows.each do |row_element|
        results << get_event_data_from_row(row_element)
      end
    end
    results
  ensure
    @driver.quit unless @driver.nil?
  end

  private

  def setup_driver
    caps = Selenium::WebDriver::Remote::Capabilities.chrome(
      'chromeOptions' => {'args' => [ 'disable-infobars', 'headless' ]}
    )
    @driver = Selenium::WebDriver.for :remote, url: 'http://localhost:4444/wd/hub', desired_capabilities: caps
  end

  def set_driver_timeout
    @driver.manage.timeouts.implicit_wait = 10
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
end
