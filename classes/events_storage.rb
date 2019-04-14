# frozen_string_literal: true

class EventsStorage
  def initialize(logger)
    @events_hash = {}
    @logger = logger
  end

  def save_or_update_event(event_id, (name, time, score, link))
    if event_exists?(event_id)
      event = find_event(event_id)
      event.update_time_and_score(time, score)
      @logger.info "Temp storage: updated event\n#{event}"
    else
      event = Event.new(name, time, score, link)
      if event.valid?
        save_event(event_id, event)
        @logger.info "Temp storage: added event\n#{event}"
      end
    end
    event
  end

  def find_event(event_id)
    @events_hash[event_id]
  end

  private

  def event_exists?(event_id)
    @events_hash.key?(event_id)
  end

  def save_event(event_id, event)
    @events_hash[event_id] = event
  end
end
