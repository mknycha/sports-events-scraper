require 'mail'

describe Mailer do
  include Mail::Matchers

  before do
    Mail::TestMailer.deliveries.clear
    allow(Settings).to receive(:recipient_email).and_return(recipient_email)
    allow(ENV).to receive(:[]).with('EMAIL_ADDRESS')
                              .and_return('fake.sender.address@example.com')
  end

  let(:recipient_email) { 'fake.email@example.com' }

  describe '#send_table_by_email' do
    let(:event1) do
      Event.new('Team A vs Team B', '1-3', '32:43', 'https://link.costam')
    end
    let(:event2) do
      Event.new('Team C vs Team D', '7-0', '22:23', 'https://link.costam_innego')
    end

    context 'when gets a valid table as an input' do
      let(:events_table) { EventsHtmlTable.new }
      let(:action) { described_class.send_table_by_email(events_table.to_s) }
      let(:expected_message_body) do
        '<h3>Hello! These events might interest you</h3>' + events_table.to_s
      end

      before do
        events_table.add_event(event1)
        events_table.add_event(event2)
      end

      it 'sends an email including html table with events' do
        action
        expect(Mail::TestMailer.deliveries.length).to eq(1)
      end

      it 'sends an email to the proper recipient' do
        action
        is_expected.to have_sent_email.to(recipient_email)
      end

      it 'includes table with events info in the email body' do
        action
        is_expected.to have_sent_email.with_body(expected_message_body)
      end
    end
  end
end
