# frozen_string_literal: true

describe WebdriverHandler do
  let(:test_page_path) { 'https://secure-refuge-50060.herokuapp.com' }
  let(:subject) { described_class.new.get_live_events_data }
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

  before do
    stub_const('WebdriverHandler::SOCCER_SCORES_PATH', test_page_path)
  end

  it 'return properly parsed events data' do
    expect(subject).to eq(expected_data)
  end
end
