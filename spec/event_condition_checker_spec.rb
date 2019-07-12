# frozen_string_literal: true

describe EventConditionChecker do
  let(:event_not_reportable_a) do
    Event.new('A vs B', '54:01', '0-1', 'https://link.costam').tap do |event|
      event.ball_possession = { home: 45, away: 55 }
      event.attacks = { home: 6, away: 3 }
      event.shots_off_target = { home: 3, away: 1 }
      event.corners = { home: 1, away: 0 }
    end
  end
  let(:event_not_reportable_b) do
    Event.new('B vs A', '54:01', '1-0', 'https://link.costam').tap do |event|
      event.ball_possession = { home: 38, away: 62 }
      event.attacks = { home: 3, away: 7 }
      event.shots_off_target = { home: 2, away: 8 }
      event.corners = { home: 1, away: 5 }
    end
  end
  let(:event_not_reportable_c) do
    Event.new('C vs D', '54:01', '1-0', 'https://link.costam').tap do |event|
      event.ball_possession = { away: 70, home: 30 }
      event.attacks = { away: 10, home: 4 }
      event.shots_off_target = { away: 7, home: 2 }
      event.corners = { away: 4, home: 2 }
    end
  end
  let(:event_not_reportable_d) do
    Event.new('A vs B', '54:01', '0-1', 'https://link.costam').tap do |event|
      event.ball_possession = { home: 62, away: 38 }
      event.attacks = { home: 7, away: 3 }
      event.shots_off_target = { home: 3, away: 2 }
      event.corners = { home: 2, away: 1 }
    end
  end
  let(:event_reportable_a) do
    Event.new('C vs D', '54:01', '1-0', 'https://link.costam').tap do |event|
      event.ball_possession = { away: 71, home: 29 }
      event.attacks = { away: 8, home: 4 }
      event.shots_off_target = { away: 10, home: 2 }
      event.corners = { away: 7, home: 2 }
    end
  end
  let(:event_reportable_b) do
    Event.new('E vs F', '54:01', '0-1', 'https://link.costam').tap do |event|
      event.ball_possession = { home: 80, away: 20 }
      event.attacks = { home: 42, away: 20 }
      event.shots_off_target = { home: 5, away: 3 }
      event.corners = { home: 4, away: 1 }
    end
  end

  def should_be_reported?(event)
    described_class.should_be_reported?(event)
  end

  def event_model_value(event)
    described_class.event_model_value(event)
  end

  describe '#should_be_reported?' do
    context 'when losing team does not fulfill the reporting conditions' do
      it 'returns false' do
        expect(should_be_reported?(event_not_reportable_a)).to be_falsey
        expect(event_model_value(event_not_reportable_a).round(4)).to eq(0.823)
        expect(should_be_reported?(event_not_reportable_b)).to be_falsey
        expect(event_model_value(event_not_reportable_b).round(4)).to eq(1.263)
        expect(should_be_reported?(event_not_reportable_c)).to be_falsey
        expect(event_model_value(event_not_reportable_c).round(4)).to eq(1.3042)
        expect(should_be_reported?(event_not_reportable_d)).to be_falsey
        expect(event_model_value(event_not_reportable_d).round(4)).to eq(1.0588)
      end
    end

    context 'when losing team meets the reporting conditions' do
      it 'returns true' do
        expect(should_be_reported?(event_reportable_a)).to be_truthy
        expect(event_model_value(event_reportable_a).round(4)).to eq(1.4653)
        expect(should_be_reported?(event_reportable_b)).to be_truthy
        expect(event_model_value(event_reportable_b).round(4)).to eq(1.48)
      end
    end
  end
end
