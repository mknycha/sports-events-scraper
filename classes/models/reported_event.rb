# frozen_string_literal: true

class ReportedEvent < ActiveRecord::Base
  TEAM_SCORED_NEXT_ALLOWED_VALUES = %w[yes no error].freeze
  EVENT_NAME_DELIMITER = ' vs '
  validates :event_id, presence: true, uniqueness: true
  validates :team_home, :team_away, :link, :reporting_time,
            :score_home, :score_away,
            :ball_possession_home, :ball_possession_away,
            :attacks_home, :attacks_away,
            :shots_on_target_home, :shots_on_target_away,
            :shots_off_target_home, :shots_off_target_away,
            :corners_home, :corners_away, presence: true
  validates :losing_team_scored_next, inclusion: { in: TEAM_SCORED_NEXT_ALLOWED_VALUES }

  def self.from_event(event)
    new.tap do |reported|
      reported.team_home, reported.team_away = event.name.split(
        EVENT_NAME_DELIMITER
      )
      reported.reporting_time = event.time
      reported.score_home = event.score_home
      reported.score_away = event.score_away
      reported.link = event.link
      reported.ball_possession_home = event.ball_possession[:home]
      reported.ball_possession_away = event.ball_possession[:away]
      reported.attacks_home = event.attacks[:home]
      reported.attacks_away = event.attacks[:away]
      reported.shots_on_target_home = event.shots_on_target[:home]
      reported.shots_on_target_away = event.shots_on_target[:away]
      reported.shots_off_target_home = event.shots_off_target[:home]
      reported.shots_off_target_away = event.shots_off_target[:away]
      reported.corners_home = event.corners[:home]
      reported.corners_away = event.corners[:away]
    end
  end
end
