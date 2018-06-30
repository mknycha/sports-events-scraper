require 'selenium-webdriver'
require 'pry'
require_relative 'settings'
require_relative 'classes/event'
require_relative 'classes/web_scraper'

# TODO:
# - Escape and return message when the element with tables was not found on page
# - Quit app with user input. User input can be received anytime, but the iteration should be finished anyway

WebScraper.new.run
