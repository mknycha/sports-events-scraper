# frozen_string_literal: true

describe WebScraper do
  include Mail::Matchers

  let(:test_page_path) { 'https://secure-refuge-50060.herokuapp.com' }
  let(:logger) { Logger.new(STDOUT) }
  let(:web_scraper) { described_class.new(logger) }

  before do
    allow(logger).to receive(:info)
    stub_const('WebdriverHandler::SOCCER_SCORES_PATH', test_page_path)
    Mail::TestMailer.deliveries.clear
  end

  describe '#run' do
    let(:action) do
      VCR.use_cassette('run_web_scraper') do
        web_scraper.run
      end
    end

    it 'sends an email' do
      action
      expect(Mail::TestMailer.deliveries.length).to eq(1)
    end

    it 'reports an event that fulfills the conditions of time and score \
        and in terms of stats' do
      expect(action).to have_sent_email.matching_body(/Barracas Central v All Boys/)
    end

    it 'does not report an event that fulfills the conditions of time and score, \
        but does not fulfill stats condition' do
      expect(action).not_to have_sent_email.matching_body(/West Brom v Brentford/)
    end

    it 'does not report an event that fulfills neither the conditions of time and score, \
        nor stats condition' do
      expect(action).not_to have_sent_email.matching_body(/Dep. Riestra v JJ Urquiza/)
    end
  end
end