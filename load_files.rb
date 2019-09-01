# frozen_string_literal: true

require 'dotenv/load'
require 'net/smtp'
require './settings'
require './db/configuration_helper.rb'

Dir['./classes/*.rb'].each { |file| require file }
Dir['./classes/models/*.rb'].each { |file| require file }
