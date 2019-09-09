# frozen_string_literal: true

require 'spec_helper'

describe WebScraper do
  let(:web_scraper) { described_class.new(Logger.new(STDOUT)) }
  let(:link) do
    'https://sports.williamhill.com/betting/en-gb/football/OB_EV14932257/liverpool-vs-man-city'
  end
  let(:event) do
    Event.new('Liverpool v Man City', '54:06', '1-0', link).tap do |event|
      event.ball_possession = { home: 35, away: 65 }
      event.attacks = { home: 1, away: 0 }
      event.shots_on_target = { home: 1, away: 2 }
      event.shots_off_target = { home: 3, away: 1 }
      event.corners = { home: 1, away: 0 }
    end
  end
  let(:event_id) { 'OB_EV14932257' }
  let(:reported_event) { ReportedEvent.from_event(event) }

  after do
    ReportedEvent.destroy_all
  end

  describe '#save_and_report_event' do
    before do
      stub_const('EventConditionChecker::ATTRIBUTES_COEFFICIENTS', stubbed_attrs)
      web_scraper.send(:setup_events_table)
    end
    let(:stubbed_attrs) do
      {
        possession: 0.017,
        attacks: 0.13,
        shots_off_target: 0.15,
        corners: 0.1,
        team_at_home: 0.1
      }
    end

    it 'saves an event to the database' do
      expect { web_scraper.send(:save_and_report_event, event, event_id) }
        .to change(ReportedEvent, :count).by(1)
    end
  end

  describe '#check_if_losing_team_scored_next' do
    let(:reported_event) { ReportedEvent.from_event(event) }

    before do
      reported_event.event_id = event_id
      reported_event.save
    end

    context 'when losing team scored' do
      before do
        event.score = '1-2'
      end

      it "saves 'yes' to an event" do
        web_scraper.send(:check_if_losing_team_scored_next, reported_event, event)
        reported_event.reload
        expect(reported_event.losing_team_scored_next).to eq('yes')
      end
    end

    context 'when winning team scored' do
      before do
        event.score = '3-0'
      end

      it "saves 'no' to an event" do
        web_scraper.send(:check_if_losing_team_scored_next, reported_event, event)
        reported_event.reload
        expect(reported_event.losing_team_scored_next).to eq('no')
      end
    end

    context 'when both team scored' do
      before do
        event.score = '2-1'
      end

      it "saves 'error' to an event" do
        web_scraper.send(:check_if_losing_team_scored_next, reported_event, event)
        reported_event.reload
        expect(reported_event.losing_team_scored_next).to eq('error')
      end
    end

    context 'when none of the teams scored' do
      it 'does not change an event' do
        web_scraper.send(:check_if_losing_team_scored_next, reported_event, event)
        reported_event.reload
        expect(reported_event.losing_team_scored_next).to eq(nil)
      end
    end
  end
end
