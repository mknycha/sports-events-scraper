# frozen_string_literal: true

require 'dotenv/load'
require 'net/smtp'
require './settings'

Dir['./classes/*.rb'].each { |file| require file }
Dir['./classes/models/*.rb'].each { |file| require file }
Dir['./classes/workers/*.rb'].each { |file| require file }
Dir['./initializers/*.rb'].each { |file| require file }