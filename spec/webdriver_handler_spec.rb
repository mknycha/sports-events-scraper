# frozen_string_literal: true

describe WebdriverHandler do
  let(:test_page_path) { 'https://secure-refuge-50060.herokuapp.com' }
  let!(:webdriver_handler) { described_class.new }

  before do
    stub_const('WebdriverHandler::SOCCER_SCORES_PATH', test_page_path)
  end

  describe '#get_live_events_data' do
    let(:expected_data) do
      [
        [
          'West Brom   v   Brentford', '53:03', '0-0',
          'https://secure-refuge-50060.herokuapp.com/betting/e/13798748/West+Brom+v+Brentford'
        ],
        [
          'Dep. Riestra   v   JJ Urquiza', '45:00', '2-0',
          'https://secure-refuge-50060.herokuapp.com/betting/e/13819684/Dep.+Riestra+v+JJ+Urquiza'
        ],
        [
          'Barracas Central   v   All Boys', '54:00', '0-2',
          'https://secure-refuge-50060.herokuapp.com/betting/e/13819672/Barracas+Central+v+All+Boys'
        ]
      ]
    end

    it 'return properly parsed events data' do
      expect(webdriver_handler.get_live_events_data).to eq(expected_data)
    end
  end

  describe '#link_to_event_stats_page' do
    let(:expected_link) do
      'https://secure-refuge-50060.herokuapp.com/betting/e/13819684/Dep.+Riestra+v+JJ+Urquiza/stats'
    end
    let(:link_to_event) { 'https://secure-refuge-50060.herokuapp.com/betting/e/13819684/Dep.+Riestra+v+JJ+Urquiza' }

    it 'return link to the page with stats' do
      expect(webdriver_handler.link_to_event_stats_page(link_to_event)).to eq(expected_link)
    end
  end

  describe '#get_event_stats' do
    let(:stats_page) do
      'https://secure-refuge-50060.herokuapp.com/betting/e/13819684/Dep.+Riestra+v+JJ+Urquiza/stats'
    end
    let(:expected_hash) do
      {
        possession: {
          home: 43,
          away: 57
        },
        danger: {
          home: 3,
          away: 2
        },
        shotsontarget: {
          home: 2,
          away: 0
        },
        shotsofftarget: {
          home: 1,
          away: 3
        },
        corners: {
          home: 0,
          away: 2
        }
      }
    end

    it 'returns the parsed stats' do
      expect(webdriver_handler.get_event_stats(stats_page)).to include(expected_hash)
    end
  end
end
