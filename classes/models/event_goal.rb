# frozen_string_literal: true
require_relative 'general_event'

# Model representing any goal scored in a match.
# This will be useful for gathering statistics.
# Although contains almost the same data as ReportedEvent model, it EventGoal may be triggered in a different time
# - event can be reported due to stats/model score change and not only due to goal.
# Besides, it will be easier to query and analyze as a separate model.
class EventGoal < GeneralEvent
  validates :event_id, presence: true
end