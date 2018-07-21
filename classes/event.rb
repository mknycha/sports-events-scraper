# frozen_string_literal: true

# Represents an event data that will be stored in events_hash
class Event
  attr_reader :name, :time, :score, :link, :reported
  attr_writer :time, :score

  def initialize(name, time, score, link)
    @name = name
    @time = time
    @score = score
    @link = link
    @reported = false
  end

  def mark_as_reported
    @reported = true
  end

  def should_be_reported?
    should_report_time? && should_report_score?
  end

  def to_s
    "TIME: #{time} SCORE: #{score} NAME: #{name} LINK: #{link}"
  end

  def update_time_and_score(time, score)
    @time = time
    @score = score
  end

  private

  def should_report_time?
    minutes = @time.split(':').first
    minutes.to_i >= Settings.reporting_conditions[:after_minutes]
  end

  def should_report_score?
    score_arr = @score.split('-')
    goals_team_a = score_arr.first.to_i
    goals_team_b = score_arr.last.to_i
    (goals_team_a - goals_team_b).abs ==
      Settings.reporting_conditions[:goal_difference]
  end
end
