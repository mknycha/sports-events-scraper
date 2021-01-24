# frozen_string_literal: true
require_relative 'general_event'

class ReportedEvent < GeneralEvent
  TEAM_SCORED_NEXT_ALLOWED_VALUES = %w[yes no error].freeze
  validates :event_id, presence: true, uniqueness: {
    message: 'ID was already reported'
  }
  validates :losing_team_scored_next, inclusion: { in: TEAM_SCORED_NEXT_ALLOWED_VALUES },
                                      allow_nil: true

end
