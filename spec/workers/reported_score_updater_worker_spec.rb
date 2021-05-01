# frozen_string_literal: true

describe ReportedScoreUpdaterWorker do
  let(:webdriver_handler_mock) { double('WebdriverHandler') }

  let(:event_id) { 'OB_EV20359319' }
  let(:name) { 'Gagra v Zugdidi' }
  let(:time) { '83:06' }
  let(:link) { 'https://sports.williamhill.com/betting/en-gb/football/OB_EV20359319/gagra-vs-zugdidi' }
  let(:link_to_stats) do
    'https://scoreboardslauncher.williamhill.com/scoreboards/events/OB_EV20359319/launch?lang=en-gb&showSuggestions=true'
  end
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

  before do
    allow(ReportedScoreUpdaterWorker).to receive(:webdriver_handler).and_return(webdriver_handler_mock)
    allow(webdriver_handler_mock).to receive(:get_event_stats).with(link_to_stats).and_return(event_stats)
    allow(webdriver_handler_mock).to receive(:quit_driver)
  end

  after do
    ReportedScore.destroy_all
  end

  describe '#perform' do
    context 'score was not reported yet' do
      let(:score) { '0-0' }
      let(:total_score) { 0 }

      before do
        allow(webdriver_handler_mock).to receive(:get_odds_for_next_team_to_score).with(link, total_score).and_return(
          event_stats
        )
      end

      it 'creates a score record, marks it as unreliable' do
        expect { ReportedScoreUpdaterWorker.perform(event_id, name, time, score, link, link_to_stats) }
          .to change(ReportedScore, :count).by(1)
        expect(ReportedScore.last.reliable).to be_falsey
      end
    end

    context 'there is already a reported score' do
      before do
        last_event_score = ReportedScore.from_event(event)
        last_event_score.odds_home_to_score_next = 0.13
        last_event_score.odds_away_to_score_next = 0.67
        last_event_score.event_id = event_id
        last_event_score.link_to_stats = link_to_stats
        last_event_score.save!
        allow(webdriver_handler_mock).to receive(:get_odds_for_next_team_to_score).with(link, total_score)
                                                                                  .and_return(event_stats)
      end

      context 'new score same as last score' do
        let(:score) { '0-0' }
        let(:new_score) { '0-0' }
        let(:total_score) { 0 }

        it 'does not create a score record' do
          expect { ReportedScoreUpdaterWorker.perform(event_id, name, time, new_score, link, link_to_stats) }
            .not_to change(ReportedScore, :count)
          expect(ReportedScore.last.reliable).to be_falsey
        end
      end

      context 'new score different than the last score' do
        let(:score) { '0-0' }
        let(:new_score) { '0-1' }
        let(:total_score) { 1 }

        it 'creates a new score record and marks it as reliable' do
          expect(ReportedScore.last.reliable).to be_falsey
          expect { ReportedScoreUpdaterWorker.perform(event_id, name, time, new_score, link, link_to_stats) }
            .to change(ReportedScore, :count).by(1)
          expect(ReportedScore.last.reliable).to be_truthy
        end
      end
    end
  end
end
