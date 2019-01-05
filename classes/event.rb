# frozen_string_literal: true

# Represents an event data that will be stored in events_hash
class Event
  attr_reader :name, :link, :reported
  attr_accessor :link_to_stats, :time, :score, :ball_possession, :attacks,
                :shots_on_target, :shots_off_target, :corners

  ATTRIBUTES_TO_ADAPT = {
    ball_possession: :possession,
    attacks: :danger,
    shots_on_target: :shotsontarget,
    shots_off_target: :shotsofftarget,
    corners: :corners
  }.freeze

  def initialize(name, time, score, link)
    @name = name.squeeze(' ')
    @time = time
    @score = score
    @link = link
    @reported = false
  end

  def mark_as_reported
    @reported = true
  end

  def update_details_from_scraped_attrs(attrs)
    ATTRIBUTES_TO_ADAPT.each do |event_attr, parsed_attr|
      send("#{event_attr}=", attrs[parsed_attr])
    end
    @attacks = attrs[:danger]
    @shots_on_target = attrs[:shotsontarget]
    @shots_off_target = attrs[:shotsofftarget]
    @corners = attrs[:corners]
  end

  def should_check_details?
    should_report_time? && should_report_score?
  end

  def should_be_reported?
    EventConditionChecker.should_be_reported?(self)
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
    minutes = @time.split(':').first.to_i
    minutes >= Settings.reporting_conditions[:after_minutes] &&
      minutes <= Settings.reporting_conditions[:before_minutes]
  end

  def should_report_score?
    score_arr = @score.split('-')
    goals_team_a = score_arr.first.to_i
    goals_team_b = score_arr.last.to_i
    (goals_team_a - goals_team_b).abs ==
      Settings.reporting_conditions[:goal_difference]
  end
end
