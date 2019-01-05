# frozen_string_literal: true

describe EventConditionChecker do
  let(:event_not_reportable_a) do
    Event.new('A vs B', '54:01', '0-1', 'https://link.costam').tap do |event|
      event.ball_possession = { home: 45, away: 55 }
      event.attacks = { home: 6, away: 3 }
      event.shots_on_target = { home: 0, away: 1 }
      event.shots_off_target = { home: 3, away: 1 }
      event.corners = { home: 1, away: 0 }
    end
  end
  let(:event_not_reportable_b) do
    Event.new('B vs A', '54:01', '1-0', 'https://link.costam').tap do |event|
      event.ball_possession = { home: 38, away: 62 }
      event.attacks = { home: 3, away: 7 }
      event.shots_on_target = { home: 0, away: 2 }
      event.shots_off_target = { home: 2, away: 3 }
      event.corners = { home: 1, away: 2 }
    end
  end
  let(:event_not_reportable_c) do
    Event.new('C vs D', '54:01', '1-0', 'https://link.costam').tap do |event|
      event.ball_possession = { away: 60, home: 40 }
      event.attacks = { away: 5, home: 4 }
      event.shots_on_target = { away: 6, home: 1 }
      event.shots_off_target = { away: 4, home: 2 }
      event.corners = { away: 4, home: 2 }
    end
  end
  let(:event_reportable_a) do
    Event.new('A vs B', '54:01', '0-1', 'https://link.costam').tap do |event|
      event.ball_possession = { home: 62, away: 38 }
      event.attacks = { home: 7, away: 3 }
      event.shots_on_target = { home: 2, away: 0 }
      event.shots_off_target = { home: 3, away: 2 }
      event.corners = { home: 2, away: 1 }
    end
  end
  let(:event_reportable_b) do
    Event.new('C vs D', '54:01', '1-0', 'https://link.costam').tap do |event|
      event.ball_possession = { away: 61, home: 39 }
      event.attacks = { away: 5, home: 4 }
      event.shots_on_target = { away: 6, home: 1 }
      event.shots_off_target = { away: 4, home: 2 }
      event.corners = { away: 4, home: 2 }
    end
  end

  describe '#should_be_reported?' do
    context 'when losing team does not fulfill the reporting conditions' do
      it 'returns false' do
        expect(described_class.should_be_reported?(event_not_reportable_a)).to be_falsey
        expect(described_class.should_be_reported?(event_not_reportable_b)).to be_falsey
        expect(described_class.should_be_reported?(event_not_reportable_c)).to be_falsey
      end
    end

    context 'when losing team meets the reporting conditions' do
      it 'returns true' do
        expect(described_class.should_be_reported?(event_reportable_a)).to be_truthy
        expect(described_class.should_be_reported?(event_reportable_b)).to be_truthy
      end
    end
  end
end