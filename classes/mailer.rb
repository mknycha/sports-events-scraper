require 'dotenv/load'
require 'net/smtp'

def send_mail
  message = 'This is the body of a test message'
  smtp = Net::SMTP.new 'smtp.gmail.com', 587
  smtp.enable_starttls
  smtp.start('gmail.com', ENV['EMAIL_ADDRESS'], ENV['EMAIL_PASSWORD'], :login) do |smtp|
    smtp.send_message message, ENV['EMAIL_ADDRESS'], Settings.recipient_email
  end
end
