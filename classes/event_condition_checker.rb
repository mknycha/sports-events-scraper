# frozen_string_literal: true

class EventConditionChecker
  ATTRIBUTES_TO_CALCULATE_WITH_FORMULA = %i[attacks shots_off_target corners team_at_home].freeze
  ATTRIBUTES_TO_READ = %i[attacks shots_off_target corners ball_possession].freeze
  ATTRIBUTES_COEFFICIENTS = {
    possession: 0.017,
    attacks: 0.13,
    shots_off_target: 0.15,
    corners: 0.1,
    team_at_home: 0.1
  }.freeze
  # Intercept is 0.15, because formula caluclated for 'shots blocked'
  # is 1 when there are no shots. See excel sheet
  INTERCEPT = 0.35
  MODEL_VALUE_CUTOFF = 1.45
  BALL_POSSESSION_ADVANTAGE_PERCENTAGE_CUTOFF = 60
  BALL_POSSESSION_ADVANTAGE_PERCENTAGE = 50

  def self.event_model_value(event)
    @event = event
    return 0.0 if any_attribute_for_calculation_missing?(event)

    winning_team = nil
    losing_team = nil
    if event.goals_home > event.goals_away
      winning_team = :home
      losing_team = :away
    else
      winning_team = :away
      losing_team = :home
    end
    stats = parse_event_stats
    calc_values = calculate_attributes_values(stats, winning_team, losing_team)
    function_value = calculate_function_value(calc_values)
    function_value + INTERCEPT
  end

  def self.should_be_reported?(event)
    winning_team = nil
    losing_team = nil
    if event.goals_home > event.goals_away
      winning_team = :home
      losing_team = :away
    else
      winning_team = :away
      losing_team = :home
    end
    event_model_value(event) > MODEL_VALUE_CUTOFF &&
      event.ball_possession[losing_team] > BALL_POSSESSION_ADVANTAGE_PERCENTAGE_CUTOFF
  end

  class << self
    private

    def any_attribute_for_calculation_missing?(event)
      ATTRIBUTES_TO_READ.any? { |attribute| event.send(attribute).nil? }
    end

    def calculate_function_value(values)
      ATTRIBUTES_COEFFICIENTS.sum do |attribute, coefficient|
        coefficient * values[attribute]
      end
    end

    def parse_event_stats
      attributes_stats = ATTRIBUTES_TO_READ.each_with_object({}) do |attribute, stats|
        stats[attribute] = @event.send(attribute.to_s)
      end
      attributes_stats[:team_at_home] = { home: 1, away: 0 }
      attributes_stats
    end

    def calculate_attributes_values(stats, winning_team, losing_team)
      attributes_values = {}
      attributes_values[:possession] = stats.dig(:ball_possession, losing_team) - BALL_POSSESSION_ADVANTAGE_PERCENTAGE
      ATTRIBUTES_TO_CALCULATE_WITH_FORMULA.each do |attribute|
        attributes_values[attribute] = formula(stats.dig(attribute, losing_team),
                                               stats.dig(attribute, winning_team))
      end
      attributes_values
    end

    def formula(value_team_a, value_team_b)
      ((value_team_a * 0.5) + 1) /
        ((value_team_b * 0.5) + 1)
    end
  end
end
