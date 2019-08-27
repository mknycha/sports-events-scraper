# frozen_string_literal: true

describe ReportedEvent do
  describe '#from_event' do
    let(:link) do
      'https://sports.williamhill.com/betting/en-gb/football/OB_EV14932257/liverpool-vs-man-city'
    end
    let(:event) do
      Event.new('Liverpool vs Man City', '54:06', '1-0', link).tap do |event|
        event.ball_possession = { home: 45, away: 55 }
        event.attacks = { home: 1, away: 0 }
        event.shots_on_target = { home: 1, away: 2 }
        event.shots_off_target = { home: 3, away: 1 }
        event.corners = { home: 1, away: 0 }
      end
    end
    let(:reported_event) { ReportedEvent.from_event(event) }

    it 'properly assigns event base attributes' do
      expect(reported_event.team_home).to eq('Liverpool')
      expect(reported_event.team_away).to eq('Man City')
      expect(reported_event.reporting_time).to eq('54:06')
      expect(reported_event.score_home).to eq(1)
      expect(reported_event.score_away).to eq(0)
      expect(reported_event.link).to eq(link)
    end

    it 'properly assigns event stats attributes' do
      expect(reported_event.ball_possession_home).to eq(45)
      expect(reported_event.ball_possession_away).to eq(55)
      expect(reported_event.attacks_home).to eq(1)
      expect(reported_event.attacks_away).to eq(0)
      expect(reported_event.shots_on_target_home).to eq(1)
      expect(reported_event.shots_on_target_away).to eq(2)
      expect(reported_event.shots_off_target_home).to eq(3)
      expect(reported_event.shots_off_target_away).to eq(1)
      expect(reported_event.corners_home).to eq(1)
      expect(reported_event.corners_away).to eq(0)
    end

    context 'with no event_id assigned' do
      it 'returns event that is not valid' do
        expect(reported_event.valid?).to be_falsey
      end
    end

    context 'with event_id assigned' do
      before do
        reported_event.event_id = 'OB_EV14932257'
      end

      it 'returns event that is valid' do
        expect(reported_event.valid?).to be_truthy
      end
    end
  end
end
