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
            '<th>Model score</th>' \
            '<th>Link</th>' \
          '</tr>' \
        '</table>'
      end

      it 'returns properly formatted table as string' do
        expect(events_html_table.to_s).to eq(expected_string)
      end
    end

    context 'when there are some events in the table' do
      let(:event1) do
        Event.new('FC Barcelona vs AC Milan', '12:34', '1-2', 'https://link.to.event')
      end
      let(:event2) do
        Event.new('FC Barcelona vs Legia Warszawa', '66:34', '3-7',
                  'https://link.to.event')
      end

      before do
        event1.link_to_stats = 'https://event/1/stats'
        event2.link_to_stats = 'https://event/2/stats'
        events_html_table.add_event(event1)
        events_html_table.add_event(event2)
      end

      it 'includes proper html tags as string' do
        %i[table th tr td].each do |tag|
          expect(events_html_table.to_s).to include("<#{tag}>", "</#{tag}>")
        end
      end

      it 'returns formatted table as string, including info about all events added' do
        %i[name score time link_to_stats].each do |attribute|
          expect(events_html_table.to_s).to include(event1.send(attribute),
                                                    event2.send(attribute))
        end
      end
    end
  end
end
