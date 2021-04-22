# frozen_string_literal: true

class EventGoalUpdaterWorker
  @queue = :general

  def self.perform(event_id, name, time, score, link, link_to_stats)
    event = Event.new(name, time, score, link)
    stats = webdriver_handler.get_event_stats(link_to_stats)
    event.update_details_from_scraped_attrs(stats)
    event_goal = EventGoal.find_last_or_initialize(event_id: event_id)
    if event.score_home != event_goal.score_home || event.score_away != event_goal.score_away
      logger.info "Found a goal stat for event: #{event}"
      eg = EventGoal.from_event(event)
      total_score = event.score_home + event.score_away
      odds = webdriver_handler.get_odds_for_next_team_to_score(event.link, total_score)
      unless odds.nil?
        eg.odds_home_to_score_next = odds[:home]
        eg.odds_away_to_score_next = odds[:away]
      end
      eg.event_id = event_id
      eg.link_to_stats = link_to_stats
      eg.save!
    end
  ensure
    webdriver_handler.quit_driver
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.webdriver_handler
    @webdriver_handler ||= WebdriverHandler.new(logger)
  end

  private_class_method :logger, :webdriver_handler
end