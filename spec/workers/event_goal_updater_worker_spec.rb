# frozen_string_literal: true

describe EventGoalUpdaterWorker do
  let(:webdriver_handler_mock) { double('WebdriverHandler') }
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

  let(:event_id) { 'OB_EV20359319' }
  let(:name) { 'Gagra v Zugdidi' }
  let(:time) { '83:06' }
  let(:link) { 'https://sports.williamhill.com/betting/en-gb/football/OB_EV20359319/gagra-vs-zugdidi' }
  let(:link_to_stats) do
    'https://scoreboardslauncher.williamhill.com/scoreboards/events/OB_EV20359319/launch?lang=en-gb&showSuggestions=true'
  end

  before do
    allow(EventGoalUpdaterWorker).to receive(:webdriver_handler).and_return(webdriver_handler_mock)
    allow(webdriver_handler_mock).to receive(:get_event_stats).with(link_to_stats).and_return(event_stats)
    allow(webdriver_handler_mock).to receive(:quit_driver)
  end

  after do
    EventGoal.destroy_all
  end

  describe '#perform' do
    context 'score different than 0-0' do
      let(:score) { '1-2' }
      let(:total_score) { 3 }

      before do
        allow(webdriver_handler_mock).to receive(:get_odds_for_next_team_to_score).with(link, total_score).and_return(
          event_stats
        )
      end

      it 'creates an event goal' do
        expect { EventGoalUpdaterWorker.perform(event_id, name, time, score, link, link_to_stats) }
          .to change(EventGoal, :count).by(1)
      end
    end

    context 'score equal to 0-0' do
      let(:score) { '0-0' }
      let(:total_score) { 0 }

      before do
        allow(webdriver_handler_mock).to receive(:get_odds_for_next_team_to_score).with(link, total_score)
                                                                                  .and_return(event_stats)
      end

      it 'does not create an event goal' do
        expect { EventGoalUpdaterWorker.perform(event_id, name, time, score, link, link_to_stats) }
          .not_to change(EventGoal, :count)
      end
    end
  end
end
