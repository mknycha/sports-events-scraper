# frozen_string_literal: true

class EventResultsPredictionUpdater
  MIN_MATCH_LENGTH_MINUTES = 105 # Includes match break

  def self.losing_team_scored_next(reported_event,
                                   new_score_home,
                                   new_score_away,
                                   event_details_empty)
    match_finished = reported_event.created_at < MIN_MATCH_LENGTH_MINUTES.minutes.ago &&
    event_details_empty
    if new_score_home.nil? || new_score_away.nil?
      'error'
    elsif match_finished
      'no'
    else
      losing_team_scored_next_comparing_to_prev_results(reported_event,
                                                        new_score_home,
                                                        new_score_away)
    end
  end

  def self.losing_team_scored_next_comparing_to_prev_results(reported_event,
                                                             new_score_home,
                                                             new_score_away)
    team_which_scored_next = which_team_scored(reported_event.score_home,
                                               reported_event.score_away,
                                               new_score_home,
                                               new_score_away)
    case team_which_scored_next
    when reported_event.losing_team
      'yes'
    when reported_event.winning_team
      'no'
    when :both
      'error'
    end
  end

  def self.which_team_scored(old_score_home, old_score_away, new_score_home, new_score_away)
    if new_score_away > old_score_away
      if new_score_home > old_score_home
        :both
      else
        :away
      end
    elsif new_score_home > old_score_home
      :home
    end
  end

  private_class_method :losing_team_scored_next_comparing_to_prev_results,
                       :which_team_scored
end
