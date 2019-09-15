# frozen_string_literal: true

class ReportedEvent < ActiveRecord::Base
  TEAM_SCORED_NEXT_ALLOWED_VALUES = %w[yes no error].freeze
  EVENT_NAME_DELIMITER = ' v '
  validates :event_id, presence: true, uniqueness: {
    message: 'ID was already reported'
  }
  validates :team_home, :team_away, :link, :reporting_time,
            :score_home, :score_away,
            :ball_possession_home, :ball_possession_away,
            :attacks_home, :attacks_away,
            :shots_on_target_home, :shots_on_target_away,
            :shots_off_target_home, :shots_off_target_away,
            :corners_home, :corners_away, presence: true
  validates :losing_team_scored_next, inclusion: { in: TEAM_SCORED_NEXT_ALLOWED_VALUES },
                                      allow_nil: true

  def self.from_event(event)
    new.tap do |reported|
      reported.team_home, reported.team_away = event.name.split(EVENT_NAME_DELIMITER)
      reported.reporting_time = event.time
      reported.score_home = event.score_home
      reported.score_away = event.score_away
      reported.link = event.link
      reported.assign_fields_from_hashes(event)
    end
  end

  def assign_fields_from_hashes(event)
    %w[ball_possession attacks shots_on_target shots_off_target corners].each do |field|
      send("#{field}_home=", event.send(field)[:home])
      send("#{field}_away=", event.send(field)[:away])
    end
  end

  def to_s
    "TIME: #{reporting_time} SCORE: #{score_home}-#{score_away}" \
    " NAME: #{team_home}-#{team_away} LINK: #{link}"
  end

  def winning_team
    score_home > score_away ? :home : :away
  end

  def losing_team
    winning_team == :home ? :away : :home
  end
end
