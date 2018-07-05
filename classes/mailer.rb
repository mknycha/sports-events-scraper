# frozen_string_literal: true

require 'dotenv/load'
require 'net/smtp'
require 'mail'
require_relative '../settings'
require_relative 'events_html_table'

class Mailer
  def initialize
    @events_html_table = EventsHtmlTable.new
  end

  def add_event_to_mail(event)
    @events_html_table.add_event(event)
  end

  def send_mail
    Mail.defaults do
      delivery_method :smtp,
                      address: 'smtp.gmail.com',
                      port: 587,
                      user_name: ENV['EMAIL_ADDRESS'],
                      password: ENV['EMAIL_PASSWORD'],
                      authentication: :plain,
                      enable_starttls_auto: true
    end
    message.deliver!
  end

  private

  def create_smtp_with_tls_enabled
    smtp = Net::SMTP.new('smtp.gmail.com', 587)
    smtp.enable_starttls
    smtp
  end

  def message
    message_body = '<h3>Hello! These events might interest you</h3>' + @events_html_table.to_s
    Mail.new do
      to      ::Settings.recipient_email
      from    ENV['EMAIL_ADDRESS']
      subject 'Live events report'
      content_type 'text/html; charset=UTF-8'
      body message_body
    end
  end
end
