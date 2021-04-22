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
  VALID_TIME_FORMAT = /\A\d{2}:\d{2}\z/.freeze
  VALID_SCORE_FORMAT = /\A\d-\d\z/.freeze
  SECOND_HALF_STARTING_TIME_MINUTES = 45.freeze

  def initialize(name, time, score, link)
    @name = name.squeeze(' ')
    @time = time
    @score = score
    @link = link
    @reported = false
  end

  def valid?
    !value_is_invalid?(@time, VALID_TIME_FORMAT) &&
      !value_is_invalid?(@score, VALID_SCORE_FORMAT)
  end

  def mark_as_reported
    @reported = true
  end

  def update_details_from_scraped_attrs(attrs)
    ATTRIBUTES_TO_ADAPT.each do |event_attr, parsed_attr|
      send("#{event_attr}=", attrs[parsed_attr])
    end
  end

  def time_and_score_reportable?
    should_report_time? && should_report_score?
  end

  def details_reportable?
    EventConditionChecker.should_be_reported?(self)
  end

  def to_s
    "TIME: #{time} SCORE: #{score} NAME: #{name} LINK: #{link}"
  end

  def readable_details
    model_value = EventConditionChecker.event_model_value(self)
    details = "BALL_POSSESSION: #{parse_to_string ball_possession} "
    details += "ATTACKS: #{parse_to_string attacks} "
    details += "SHOTS_ON_TARGET: #{parse_to_string shots_on_target} "
    details += "SHOTS_OFF_TARGET: #{parse_to_string shots_off_target} "
    details += "CORNERS: #{parse_to_string corners} "
    details += "MODEL SCORE: #{format('%.2f', model_value)}"
    details
  end

  def update_time_and_score(time, score)
    @time = time
    @score = score
  end

  def score_home
    score_arr.first.to_i
  end

  def score_away
    score_arr.last.to_i
  end

  def winning_team
    score_home > score_away ? :home : :away
  end

  def losing_team
    winning_team == :home ? :away : :home
  end

  def second_half_started?
    time_split = @time.split(':')
    minutes = time_split.first.to_i
    seconds = time_split.second.to_i
    # If seconds is 0, it may be part-time break in a match
    minutes > SECOND_HALF_STARTING_TIME_MINUTES && seconds > 0
  end

  private

  def value_is_invalid?(value, valid_format_regex)
    return true if value.nil?

    value_formatted = value[valid_format_regex]
    value_formatted.nil?
  end

  def should_report_time?
    minutes = @time.split(':').first.to_i
    minutes >= Settings.reporting_conditions[:after_minutes] &&
      minutes <= Settings.reporting_conditions[:before_minutes]
  end

  def should_report_score?
    (score_home - score_away).abs ==
      Settings.reporting_conditions[:goal_difference]
  end

  def score_arr
    @score.split('-')
  end

  def parse_to_string(attribute)
    return nil unless attribute.is_a?(Hash)

    "#{attribute[:home]}-#{attribute[:away]}"
  end
end
