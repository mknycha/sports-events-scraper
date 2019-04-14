# frozen_string_literal: true

describe EventsStorage do
  let(:event_1_id) { 'OB_EV14441801' }
  let(:event_1_details) do
    ['West Brom v Brentford', '53:03', '1-0', "fake-site/link/to/event/#{event_1_id}"]
  end
  let(:logger) { Logger.new(STDOUT) }
  let(:storage) { described_class.new(logger) }
  let(:action) do
    storage.save_or_update_event(event_1_id, event_1_details)
  end

  it 'saves an event' do
    expect(storage).to receive(:save_event)
    action
  end

  context 'when an event has invalid score format' do
    let(:event_1_details) do
      ['West Brom v Brentford', '53:03', 'Goal!', "fake-site/link/to/event/#{event_1_id}"]
    end

    it 'does not save that event' do
      expect(storage).not_to receive(:save_event)
      action
    end
  end

  context 'when an event has invalid time format' do
    let(:event_1_details) do
      ['West Brom v Brentford', 'Live', '1-0', "fake-site/link/to/event/#{event_1_id}"]
    end

    it 'does not save that event' do
      expect(storage).not_to receive(:save_event)
      action
    end
  end
end
