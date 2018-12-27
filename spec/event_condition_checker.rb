# frozen_string_literal: true

describe EventConditionChecker do
  let(:event_not_reportable_a) do
    event = Event.new('A vs B', '11:01', '0-1', 'https://link.costam')
    event.ball_possession = { home: 45, away: 55 }
    event.attacks = { home: 6, away: 3 }
    event.shots_on_target = { home: 0, away: 1 }
    event.shots_off_target = { home: 3, away: 1 }
    event.corners = { home: 1, away: 0 }
    event
  end
  let(:event_not_reportable_b) do
    event = Event.new('B vs A', '11:01', '1-0', 'https://link.costam')
    event.ball_possession = { away: 45, home: 55 }
    event.attacks = { away: 6, home: 3 }
    event.shots_on_target = { away: 0, home: 1 }
    event.shots_off_target = { away: 3, home: 1 }
    event.corners = { away: 1, home: 0 }
    event
  end
  let(:event_reportable_a) do
    event = Event.new('A vs B', '11:01', '0-1', 'https://link.costam')
    event.ball_possession = { home: 62, away: 38 }
    event.attacks = { home: 7, away: 3 }
    event.shots_on_target = { home: 2, away: 0 }
    event.shots_off_target = { home: 3, away: 2 }
    event.corners = { home: 2, away: 1 }
    event
  end

  describe '#should_be_reported?' do
    context 'when losing team does not fulfill the reporting conditions' do
      it 'returns false' do
        expect(described_class.should_be_reported?(event_not_reportable_a)).to be_falsey
        expect(described_class.should_be_reported?(event_not_reportable_b)).to be_falsey
      end
    end

    context 'when losing team meets the reporting conditions' do
      it 'returns true' do
        expect(described_class.should_be_reported?(event_reportable_a)).to be_truthy
      end
    end
  end
end
