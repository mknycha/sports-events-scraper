# frozen_string_literal: true

describe ResultCheckerWorker do
  let(:webdriver_handler_mock) { double('WebdriverHandler') }
  let(:event_id) { 'OB_EV20359319' }
  let(:name) { 'Gagra v Zugdidi' }
  let(:time) { '93:06' }
  let(:score) { '2-1' }
  let(:link) { 'https://sports.williamhill.com/betting/en-gb/football/OB_EV20359319/gagra-vs-zugdidi' }
  let(:event_stats) do
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

  let(:event) do
    event = Event.new(name, time, score, link)
    event.update_details_from_scraped_attrs(event_stats)
    event
  end
  let(:reported_event) do
    reported_event = ReportedEvent.from_event(event)
    reported_event.event_id = event_id
    reported_event
  end

  before do
    reported_event.save!
    allow(ResultCheckerWorker).to receive(:webdriver_handler).and_return(webdriver_handler_mock)
    allow(webdriver_handler_mock).to receive(:find_event_details).with(event_id)
    allow(webdriver_handler_mock).to receive(:quit_driver)
  end

  after do
    ReportedEvent.destroy_all
  end

  context 'the score did not change' do
    context 'the event has not finish yet' do
      it 'does not update the reported event' do
        expect(reported_event.losing_team_scored_next).to eq(nil)
        ResultCheckerWorker.perform(event_id, event.score_home, event.score_away)
        expect(reported_event.reload.losing_team_scored_next).to eq(nil)
      end
    end

    context 'event finished' do
      before do
        reported_event.created_at = 110.minutes.ago
        reported_event.save!
      end

      it 'updates the reported event' do
        expect(reported_event.losing_team_scored_next).to eq(nil)
        ResultCheckerWorker.perform(event_id, event.score_home, event.score_away)
        expect(reported_event.reload.losing_team_scored_next).to eq('no')
      end
    end
  end
end
