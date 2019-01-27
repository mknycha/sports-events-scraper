# frozen_string_literal: true

describe WebScraper do
  include Mail::Matchers

  let(:logger) { Logger.new(STDOUT) }
  let(:web_scraper) { described_class.new(logger) }

  before do
    allow(logger).to receive(:info)
    stub_const('WebdriverHandler::SOCCER_SCORES_PATH', test_page_path)
  end

  describe '#run' do
    let(:test_page_path) { 'https://secure-refuge-50060.herokuapp.com' }
    let(:action) do
      VCR.use_cassette('web_scraper_run') do
        web_scraper.run
      end
    end

    context 'for an event that fulfills the conditions of time and score \
             and in terms of stats' do
      it 'sends it in an email' do
        expect(action).to have_sent_email.matching_body(/Barracas Central v All Boys/)
      end

      context 'when the event was already reported' do
        before do
          action
          Mail::TestMailer.deliveries.clear
        end

        it 'does not report already reported event' do
          expect(action).not_to have_sent_email.matching_body(
            /Barracas Central v All Boys/
          )
        end
      end
    end

    it 'does not report an event that fulfills the conditions of time and score, \
        but does not fulfill stats condition' do
      expect(action).not_to have_sent_email.matching_body(/West Brom v Brentford/)
    end

    it 'does not report an event that fulfills neither the conditions of time and score, \
        nor stats condition' do
      expect(action).not_to have_sent_email.matching_body(/Dep. Riestra v JJ Urquiza/)
    end

    context 'when there are events with an invalid format' do
      let(:test_page_path) do
        'https://secure-refuge-50060.herokuapp.com/invalid_format_events'
      end
      let(:action) do
        VCR.use_cassette('web_scraper_run_for_invalid_format_events') do
          web_scraper.run
        end
      end

      before do
        stub_const('WebdriverHandler::SOCCER_SCORES_PATH', test_page_path)
      end

      it 'does not try to process those events' do
        expect(web_scraper).to receive(:process_event).once
        action
      end
    end
  end
end
