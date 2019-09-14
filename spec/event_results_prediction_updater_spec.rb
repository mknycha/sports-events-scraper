# frozen_string_literal: true

require 'spec_helper'

describe EventResultsPredictionUpdater do
  after do
    ReportedEvent.destroy_all
  end

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

  before do
    reported_event.event_id = event_id
    reported_event.save
  end

  describe '#losing_team_scored_next' do
    context 'when the match has finished' do
      before do
        reported_event.created_at = (
          described_class::MIN_MATCH_LENGTH_MINUTES + 10
        ).minutes.ago
      end

      it 'returns no' do
        expect(described_class.losing_team_scored_next(reported_event,
                                                       event, true)).to eq('no')
      end
    end

    context 'when the match could not be found' do
      it "returns 'error'" do
        expect(described_class.losing_team_scored_next(reported_event,
                                                       nil, false)).to eq('error')
      end
    end

    context 'when the match was found and has not finished yet' do
      it 'compares the score with the current one and returns flag based on it' do
        expected_flag = described_class.losing_team_scored_next_comparing_to_prev_results(
          reported_event,
          event
        )
        expect(described_class.losing_team_scored_next(reported_event,
                                                       event, false)).to eq(expected_flag)
      end
    end
  end

  describe '#losing_team_scored_next_comparing_to_prev_results' do
    context 'when losing team scored' do
      before do
        event.score = '1-2'
      end

      it "saves 'yes' to an event" do
        result = described_class.send(:losing_team_scored_next_comparing_to_prev_results,
                                      reported_event, event)
        expect(result).to eq('yes')
      end
    end

    context 'when winning team scored' do
      before do
        event.score = '3-0'
      end

      it "saves 'no' to an event" do
        result = described_class.send(:losing_team_scored_next_comparing_to_prev_results,
                                      reported_event, event)
        expect(result).to eq('no')
      end
    end

    context 'when both team scored' do
      before do
        event.score = '2-1'
      end

      it "saves 'error' to an event" do
        result = described_class.send(:losing_team_scored_next_comparing_to_prev_results,
                                      reported_event, event)
        expect(result).to eq('error')
      end
    end

    context 'when none of the teams scored' do
      it 'does not change an event' do
        result = described_class.send(:losing_team_scored_next_comparing_to_prev_results,
                                      reported_event, event)
        expect(result).to eq(nil)
      end
    end
  end
end
