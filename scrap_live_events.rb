Bundler.require
require_relative 'load_files'
require_relative 'mailer_initializer'

class App
  def initialize
    @retries = 0
    @logger = DoubleLogger.new
  end

  def run
    @logger.info 'Starting event scraper, hit CTRL+C to quit'
    begin
      while Time.now < finish_time
        web_scraper.run
        sleep_thread.join
      end
    rescue Net::ReadTimeout,
           Selenium::WebDriver::Error::StaleElementReferenceError,
           StatsReadingError => e
      log_error e
      @logger.info 'Retrying...'
      retry
    rescue => e # rubocop:disable Style/RescueStandardError
      handle_error(e)
    end
  end

  private

  trap 'SIGINT' do
    puts 'Goodbye!'
    exit 130
  end

  def sleep_thread
    Thread.new { sleep Settings.time_interval }
  end

  def web_scraper
    @web_scraper ||= WebScraper.new(@logger)
  end

  def handle_error(err)
    log_error(err)
    raise err
  end

  def log_error(err)
    @logger.error err.message
    err.backtrace.each { |line| @logger.error line }
  end

  def finish_time
    Time.local(Time.now.year, Time.now.month, Time.now.day, 22, 30)
  end
end

App.new.run
