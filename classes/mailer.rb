# frozen_string_literal: true

require 'dotenv/load'
require 'net/smtp'

class Mailer
  def initialize
  end

  def add_event_to_mail(event)
  end

  def send_mail
    message = 'This is the body of a test message'
    smtp = create_smtp_with_tls_enabled
    smtp.start('gmail.com', ENV['EMAIL_ADDRESS'], ENV['EMAIL_PASSWORD'], :login)
    smtp.send_message message, ENV['EMAIL_ADDRESS'], Settings.recipient_email
    smtp.finish
  end

  private

  def create_smtp_with_tls_enabled
    Net::SMTP.new('smtp.gmail.com', 587).enable_starttls
  end
end
