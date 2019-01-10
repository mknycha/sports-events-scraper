# frozen_string_literal: true

class EventsStorage
  def initialize(logger)
    @events_hash = {}
    @logger = logger
  end

  def save_or_update_event(name, time, score, link)
    event_id = parse_event_id(link)
    if event_exists?(event_id)
      event = find_event(event_id)
      event.update_time_and_score(time, score)
      @logger.info "Temp storage: updated event\n#{event}"
    else
      event = Event.new(name, time, score, link)
      save_event(event_id, event)
      @logger.info "Temp storage: added event\n#{event}"
    end
    event
  end

  private

  def parse_event_id(link)
    link.split('/')[-2]
  end

  def event_exists?(event_id)
    @events_hash.key?(event_id)
  end

  def find_event(event_id)
    @events_hash[event_id]
  end

  def save_event(event_id, event)
    @events_hash[event_id] = event
  end
end
