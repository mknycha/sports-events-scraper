# frozen_string_literal: true

describe WebScraper do
  include Mail::Matchers

  let(:logger) { Logger.new(STDOUT) }
  let(:web_scraper) { described_class.new(logger) }
  let(:reporting_conditions) do
    { after_minutes: 53, before_minutes: 57, goal_difference: 1 }
  end
  let(:webdriver_handler) { instance_double('WebdriverHandler') }
  let(:event_1_id) { 'OB_EV14441801' }
  let(:event_2_id) { 'OB_EV14441802' }
  let(:event_3_id) { 'OB_EV14441803' }
  let(:event_4_id) { 'OB_EV14441804' }
  let(:event_1_details) do
    ['West Brom v Brentford', '53:03', '1-0', "fake-site/link/to/event/#{event_1_id}"]
  end
  let(:event_2_details) do
    ['Dep. Riestra v JJ Urquiza', '45:00', '2-0', "fake-site/link/to/event/#{event_2_id}"]
  end
  let(:event_3_details) do
    ['Barracas Central v All Boys', '54:00', '0-1',
     "fake-site/link/to/event/#{event_3_id}"]
  end
  let(:event_4_details) do
    ['Central Cordoba v Platense', '53:14', '0-1',
     "fake-site/link/to/event/#{event_4_id}"]
  end
  let(:event_1_stats) do
    {
      possession: { home: 55, away: 45 },
      danger: { home: 3, away: 6 },
      shotsontarget: { home: 1, away: 0 },
      shotsofftarget: { home: 1, away: 3 },
      corners: { home: 0, away: 1 }
    }
  end
  let(:event_2_stats) do
    {
      possession: { home: 43, away: 57 },
      danger: { home: 3, away: 2 },
      shotsontarget: { home: 2, away: 0 },
      shotsofftarget: { home: 1, away: 3 },
      corners: { home: 0, away: 2 }
    }
  end
  let(:event_3_stats) do
    {
      possession: { home: 62, away: 38 },
      danger: { home: 7, away: 3 },
      shotsontarget: { home: 2, away: 0 },
      shotsofftarget: { home: 3, away: 2 },
      corners: { home: 2, away: 1 }
    }
  end
  let(:event_4_stats) do
    {
      possession: { home: 62, away: 38 },
      danger: { home: 7, away: 3 },
      shotsontarget: { home: 2, away: 0 },
      shotsofftarget: { home: 10, away: 2 },
      corners: { home: 2, away: 1 }
    }
  end

  before do
    allow(Settings).to receive(:reporting_conditions).and_return(
      reporting_conditions
    )
    allow(logger).to receive(:info)
    allow(WebdriverHandler).to receive(:new).and_return(webdriver_handler)
    allow(webdriver_handler).to receive(:find_event_ids).and_return(
      [event_1_id, event_2_id, event_3_id, event_4_id]
    )

    allow(webdriver_handler).to receive(:find_event_details)
      .with(event_1_id).and_return(event_1_details)
    allow(webdriver_handler).to receive(:find_event_details)
      .with(event_2_id).and_return(event_2_details)
    allow(webdriver_handler).to receive(:find_event_details)
      .with(event_3_id).and_return(event_3_details)
    allow(webdriver_handler).to receive(:find_event_details)
      .with(event_4_id).and_return(event_4_details)

    allow(webdriver_handler).to receive(:link_to_event_stats_page)
      .with("fake-site/link/to/event/#{event_1_id}")
      .and_return("fake-site/link/to/event/#{event_1_id}/stats")
    allow(webdriver_handler).to receive(:link_to_event_stats_page)
      .with("fake-site/link/to/event/#{event_2_id}")
      .and_return("fake-site/link/to/event/#{event_2_id}/stats")
    allow(webdriver_handler).to receive(:link_to_event_stats_page)
      .with("fake-site/link/to/event/#{event_3_id}")
      .and_return("fake-site/link/to/event/#{event_3_id}/stats")
    allow(webdriver_handler).to receive(:link_to_event_stats_page)
      .with("fake-site/link/to/event/#{event_4_id}")
      .and_return("fake-site/link/to/event/#{event_4_id}/stats")

    allow(webdriver_handler).to receive(:second_half_available?)
      .with("fake-site/link/to/event/#{event_1_id}/stats").and_return(true)
    allow(webdriver_handler).to receive(:second_half_available?)
      .with("fake-site/link/to/event/#{event_2_id}/stats").and_return(true)
    allow(webdriver_handler).to receive(:second_half_available?)
      .with("fake-site/link/to/event/#{event_3_id}/stats").and_return(true)
    allow(webdriver_handler).to receive(:second_half_available?)
      .with("fake-site/link/to/event/#{event_4_id}/stats").and_return(false)

    allow(webdriver_handler).to receive(:get_event_stats)
      .with("fake-site/link/to/event/#{event_1_id}/stats").and_return(event_1_stats)
    allow(webdriver_handler).to receive(:get_event_stats)
      .with("fake-site/link/to/event/#{event_2_id}/stats").and_return(event_2_stats)
    allow(webdriver_handler).to receive(:get_event_stats)
      .with("fake-site/link/to/event/#{event_3_id}/stats").and_return(event_3_stats)
    allow(webdriver_handler).to receive(:get_event_stats)
      .with("fake-site/link/to/event/#{event_4_id}/stats").and_return(event_4_stats)

    allow(webdriver_handler).to receive(:quit_driver)
  end

  describe '#run' do
    let(:action) do
      web_scraper.run
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

    it 'does not report an event for which second half is unavailable' do
      expect(action).not_to have_sent_email.matching_body(/Central Cordoba v Platense/)
    end
  end
end
