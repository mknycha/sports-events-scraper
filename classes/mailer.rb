# frozen_string_literal: true

class Mailer
  def initialize
    Mail.defaults do
      delivery_method :smtp,
                      address: 'smtp.gmail.com',
                      port: 587,
                      user_name: ENV['EMAIL_ADDRESS'],
                      password: ENV['EMAIL_PASSWORD'],
                      authentication: :plain,
                      enable_starttls_auto: true
    end
  end

  def send_table_by_email(events_html_table_as_string)
    message(events_html_table_as_string).deliver!
  end

  private

  def create_smtp_with_tls_enabled
    smtp = Net::SMTP.new('smtp.gmail.com', 587)
    smtp.enable_starttls
    smtp
  end

  def message(events_html_table_as_string)
    message_body = '<h3>Hello! These events might interest you</h3>' +
                   events_html_table_as_string
    Mail.new do
      to      ::Settings.recipient_email
      from    ENV['EMAIL_ADDRESS']
      subject 'Live events report'
      content_type 'text/html; charset=UTF-8'
      body message_body
    end
  end
end
