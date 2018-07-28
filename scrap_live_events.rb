Bundler.require
require 'dotenv/load'
require 'net/smtp'
require_relative 'mailer_initializer'
require_relative 'settings'
Dir['classes/*.rb'].each { |file| require_relative file }

class App
  def run
    puts 'Starting event scraper, hit CTRL+C to quit'
    begin
      @logger = initialize_logger
      loop do
        web_scraper.run
        sleep_thread.join
      end
    rescue Net::ReadTimeout => timeout_err
      log_error timeout_err
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

  def initialize_logger
    Logger.new('logfile.log', 'daily')
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
end

App.new.run
