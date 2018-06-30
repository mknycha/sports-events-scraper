require 'selenium-webdriver'
require 'pry'
require_relative 'settings'
require_relative 'classes/event'
require_relative 'classes/web_scraper'

# TODO:
# - Escape and return message when the element with tables was not found on page
# - Quit app with user input. User input can be received anytime, but the iteration should be finished anyway

def quit?
  # See if a 'Q' has been typed yet
  while c = STDIN.read_nonblock(1)
    return true if %w[Q q].include?(c)
  end
  false # No 'Q' found
rescue Errno::EINTR, Errno::EAGAIN
  # when the device is slow or nothing to be read
  false
rescue EOFError
  # quit on the end of the input stream
  # (user hit CTRL-D)
  true
end

puts 'Starting event scraper, hit CTRL+D or Q and then ENTER to quit'
web_scraper = WebScraper.new

loop do
  web_scraper.run
  exit_on_input_thread = create_exit_on_input_thread
  sleep Settings.time_interval
  exit_on_input_thread.terminate
end

def create_exit_on_input_thread
  Thread.new { puts 'Goodbye!' && exit if quit? }
end
