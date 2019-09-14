# frozen_string_literal: true

class EventsStorage
  def initialize(logger)
    @events_hash = {}
    @logger = logger
  end

  def save_or_update_event(event_id, (name, time, score, link))
    event = find_event(event_id).dup
    label = ''
    if event.nil?
      event = Event.new(name, time, score, link)
      label = 'added'
    else
      event.update_time_and_score(time, score)
      label = 'updated'
    end
    return event unless event.valid?

    save_event(event_id, event)
    @logger.info "Temp storage: #{label} event\n#{event}"
    event
  end

  def find_event(event_id)
    @events_hash[event_id]
  end

  private

  def save_event(event_id, event)
    @events_hash[event_id] = event
  end
end
