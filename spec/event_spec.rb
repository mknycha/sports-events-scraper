require_relative '../classes/event'
require_relative '../settings'

describe Event do
  let(:reporting_conditions) do
    { after_minutes: 10, before_minutes: 20, goal_difference: 3 }
  end
  let(:event) do
    Event.new('Falubaz vs Stal Gorzow', '11:01', '1-4', 'https://link.costam')
  end

  before do
    allow(Settings).to receive(:reporting_conditions).and_return(
      reporting_conditions
    )
  end

  describe '#should_report_time?' do
    context 'when event time falls into reporting conditions' do
      it 'returns true' do
        expect(event.send(:should_report_time?)).to be_truthy
      end
    end

    context 'when event time does not meet the requirement of after_minutes setting' do
      before { event.time = '9:55' }

      it 'returns false' do
        expect(event.send(:should_report_time?)).to be_falsey
      end
    end

    context 'when event time does not meet the requirement of before_minutes setting' do
      before { event.time = '21:05' }

      it 'returns false' do
        expect(event.send(:should_report_time?)).to be_falsey
      end
    end
  end

  describe '#should_report_score?' do
    context 'when the goal difference is equal to number from settings' do
      it 'returns true' do
        expect(event.send(:should_report_score?)).to be_truthy
      end
    end

    context 'when the goal difference is different than number in settings' do
      before { event.score = '1-2' }

      it 'returns false' do
        expect(event.send(:should_report_score?)).to be_falsey
      end
    end
  end

  describe '#mark_as_reported' do
    context 'when event was not reported yet' do
      it 'changes reported flag' do
        expect { event.mark_as_reported }.to change(event, :reported)
          .from(false).to(true)
      end
    end

    context 'when event was already reported' do
      before { event.mark_as_reported }

      it 'does not change reported flag' do
        expect { event.mark_as_reported }.not_to change(event, :reported)
      end
    end
  end
end
