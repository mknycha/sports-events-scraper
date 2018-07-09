require_relative '../classes/events_html_table'
require_relative '../classes/event'

describe EventsHtmlTable do
  describe '#to_s' do
    let(:events_html_table) { EventsHtmlTable.new }

    context 'when table is empty' do
      let(:expected_string) do
        '<table>' \
          '<tr>' \
            '<th>Name</th>' \
            '<th>Score</th>' \
            '<th>Time</th>' \
            '<th>Link</th>' \
          '</tr>' \
        '</table>'
      end

      it 'returns properly formatted table as string' do
        expect(events_html_table.to_s).to eq(expected_string)
      end
    end

    context 'when there are some events in the table' do
      let(:event1) { Event.new('FC Barcelona vs AC Milan', '1-2', '12:34', 'https://link.to.event') }
      let(:event2) { Event.new('FC Barcelona vs Legia Warszawa', '3-7', '66:34', 'https://link.to.event') }

      before do
        events_html_table.add_event(event1)
        events_html_table.add_event(event2)
      end

      it 'returns formatted table as string, including info about all events added' do
        %i[name score time link].each do |attribute|
          expect(events_html_table.to_s).to include(event1.send(attribute))
          expect(events_html_table.to_s).to include(event2.send(attribute))
        end
      end
    end
  end
end
