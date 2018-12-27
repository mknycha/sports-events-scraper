# frozen_string_literal: true

class EventConditionChecker
  ATTRIBUTES_TO_CALCULATE_WITH_FORMULA = %i[attacks shots_on_target
                                            shots_off_target corners].freeze
  ATTRIBUTES_COEFFICIENTS = {
    possession: 0.17,
    attacks: 0.13,
    shots_on_target: 0.2,
    shots_off_target: 0.15,
    corners: 0.1,
    team_at_home: 0.1
  }.freeze

  def self.should_be_reported?(event)
    # move this to parser and test separately
    # It would be better to change the format in which stats are saved for an event
    # E.g. Event can have attribute like home_details
    score_arr = event.score.split('-')
    goals_home = score_arr.first.to_i
    goals_away = score_arr.last.to_i
    winning_team = nil
    losing_team = nil
    attributes_values = {}
    if goals_home > goals_away
      winning_team = :home
      losing_team = :away
      attributes_values[:team_at_home] = 0
    else
      winning_team = :away
      losing_team = :home
      attributes_values[:team_at_home] = 1
    end
    attributes_values[:possession] = event.ball_possession[losing_team] - 50
    ATTRIBUTES_TO_CALCULATE_WITH_FORMULA.each do |attribute|
      stats = event.send(attribute.to_s)
      attributes_values[attribute] = formula(stats[losing_team], stats[winning_team])
    end
    sum = 0 # There is definitely a better way to sum this
    ATTRIBUTES_COEFFICIENTS.each do |attribute, coefficient|
      sum += coefficient * attributes_values[attribute]
    end
    sum > 1.45
  end

  class << self
    private

    def formula(value_team_a, value_team_b)
      ((value_team_a * 0.5) + 1) /
        ((value_team_b * 0.5) + 1)
    end
  end
end
