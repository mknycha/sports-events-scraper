Bundler.require
require 'dotenv/load'
require 'net/smtp'
require_relative 'mailer_initializer'
require_relative 'settings'
require_relative 'classes/event'
require_relative 'classes/web_scraper'
require_relative 'classes/events_html_table'
require_relative 'classes/mailer'

class App
  def run
    puts 'Starting event scraper, hit CTRL+C to quit'
    web_scraper = WebScraper.new

    loop do
      web_scraper.run
      sleep_thread.join
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
end

App.new.run
