# frozen_string_literal: true

describe EventConditionChecker do
  before do
    stub_const('EventConditionChecker::ATTRIBUTES_COEFFICIENTS', stubbed_attrs)
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

  def event_model_value(event)
    described_class.event_model_value(event)
  end

  def formula(value_team_a, value_team_b)
    ((value_team_a * 0.5) + 1) / ((value_team_b * 0.5) + 1)
  end

  def formula_change(base_event, modified_event, attribute_name)
    formula(modified_event.send(attribute_name)[:home], modified_event.send(attribute_name)[:away]) - formula(base_event.send(attribute_name)[:home], base_event.send(attribute_name)[:away])
  end

  describe '#event_model_value' do
    let(:base_event) do
      Event.new('A vs B', '54:01', '0-1', 'https://link.costam').tap do |event|
        event.ball_possession = { home: 45, away: 55 }
        event.attacks = { home: 1, away: 0 }
        event.shots_off_target = { home: 3, away: 1 }
        event.corners = { home: 1, away: 0 }
      end
    end

    let(:losing_away_team_event) do
      Event.new('A vs B', '54:01', '1-0', 'https://link.costam').tap do |event|
        event.ball_possession = { home: 55, away: 45 }
        event.attacks = { home: 0, away: 1 }
        event.shots_off_target = { home: 1, away: 3 }
        event.corners = { home: 0, away: 1 }
      end
    end

    it 'includes possession stat in the calculation' do
      modified_event = base_event.clone
      modified_event.ball_possession = { home: 30, away: 70 }
      new_model_value = event_model_value(modified_event)
      old_model_value = event_model_value(base_event)
      possesion_change = modified_event.ball_possession[:away] - base_event.ball_possession[:away]
      expect(old_model_value - possesion_change * EventConditionChecker::ATTRIBUTES_COEFFICIENTS[:possession]).to eq(
        new_model_value
      )
    end

    it 'includes attacks stat in the calculation' do
      modified_event = base_event.clone
      modified_event.attacks = { home: 2, away: 0 }
      new_model_value = event_model_value(modified_event)
      old_model_value = event_model_value(base_event)
      attacks_change = formula_change(base_event, modified_event, 'attacks')
      expected_value = old_model_value + attacks_change * EventConditionChecker::ATTRIBUTES_COEFFICIENTS[:attacks]
      expect(expected_value).to eq(new_model_value.round(3))
    end

    it 'includes shots_off_target stat in the calculation' do
      modified_event = base_event.clone
      modified_event.shots_off_target = { home: 2, away: 0 }
      new_model_value = event_model_value(modified_event)
      old_model_value = event_model_value(base_event)
      shots_off_target_change = formula_change(base_event, modified_event, 'shots_off_target')
      expect(old_model_value + shots_off_target_change * EventConditionChecker::ATTRIBUTES_COEFFICIENTS[:shots_off_target]).to eq(
        new_model_value
      )
    end

    it 'includes corners stat in the calculation' do
      modified_event = base_event.clone
      modified_event.corners = { home: 2, away: 0 }
      new_model_value = event_model_value(modified_event)
      old_model_value = event_model_value(base_event)
      corners_change = formula_change(base_event, modified_event, 'corners')
      expect(old_model_value + corners_change * EventConditionChecker::ATTRIBUTES_COEFFICIENTS[:corners]).to eq(
        new_model_value
      )
    end

    it 'includes team_at_home in the calculation' do
      team_away_value = event_model_value(losing_away_team_event)
      team_at_home_value = event_model_value(base_event)
      team_at_home_change = formula(1, 0) - formula(0, 1)
      expect(team_at_home_value - team_at_home_change * EventConditionChecker::ATTRIBUTES_COEFFICIENTS[:team_at_home]).to eq(
        team_away_value
      )
    end
  end

  describe '#should_be_reported?' do
    let(:base_event) do
      Event.new('A vs B', '54:01', '0-1', 'https://link.costam').tap do |event|
        event.ball_possession = { home: 45, away: 55 }
        event.attacks = { home: 1, away: 0 }
        event.shots_off_target = { home: 3, away: 1 }
        event.corners = { home: 1, away: 0 }
      end
    end

    before do
      stub_const('EventConditionChecker::MODEL_VALUE_CUTOFF', 1.45)
      stub_const('EventConditionChecker::BALL_POSSESSION_ADVANTAGE_PERCENTAGE', 50)
      stub_const('EventConditionChecker::BALL_POSSESSION_ADVANTAGE_PERCENTAGE_CUTOFF', 60)
    end

    context 'when model score is higher than cutoff value' do
      before do
        allow(described_class).to receive(:event_model_value).and_return(1.46)
      end

      context 'when possession is above cutoff value' do
        before do
          base_event.ball_possession = { home: 61, away: 39 }
        end

        it 'returns true' do
          expect(described_class.should_be_reported?(base_event)).to be_truthy
        end
      end

      context 'when possession is below cutoff value' do
        it 'returns false' do
          expect(described_class.should_be_reported?(base_event)).to be_falsey
        end
      end
    end

    context 'when model score is below the cutoff value' do
      before do
        allow(described_class).to receive(:event_model_value).and_return(1.36)
      end

      it 'returns false' do
        expect(described_class.should_be_reported?(base_event)).to be_falsey
      end
    end
  end
end
