# frozen_string_literal: true

class EventResultsPredictionUpdater
  MIN_MATCH_LENGTH_MINUTES = 105 # Includes match break

  def self.losing_team_scored_next(reported_event, updated_event, event_details_empty)
    match_finished = reported_event.created_at < MIN_MATCH_LENGTH_MINUTES.minutes.ago &&
    event_details_empty
    if updated_event.nil?
      'error'
    elsif match_finished
      'no'
    else
      losing_team_scored_next_comparing_to_prev_results(reported_event,
                                                        updated_event)
    end
  end

  def self.losing_team_scored_next_comparing_to_prev_results(reported_event,
                                                             updated_event)
    team_which_scored_next = which_team_scored(reported_event, updated_event)
    case team_which_scored_next
    when reported_event.losing_team
      'yes'
    when reported_event.winning_team
      'no'
    when :both
      'error'
    end
  end

  def self.which_team_scored(reported_event, updated_event)
    if updated_event.score_away > reported_event.score_away
      if updated_event.score_home > reported_event.score_home
        :both
      else
        :away
      end
    elsif updated_event.score_home > reported_event.score_home
      :home
    end
  end

  private_class_method :losing_team_scored_next_comparing_to_prev_results,
                       :which_team_scored
end
