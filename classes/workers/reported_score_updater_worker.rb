# frozen_string_literal: true

class ReportedScoreUpdaterWorker
  @queue = :general

  def self.perform(event_id, name, time, score, link, link_to_stats)
    event = Event.new(name, time, score, link)
    stats = webdriver_handler.get_event_stats(link_to_stats)
    event.update_details_from_scraped_attrs(stats)

    last_event_score = if ReportedScore.exists?(event_id: event_id)
      ReportedScore.where(event_id: event_id).last
    else
      new_event_score = ReportedScore.from_event(event)
      new_event_score.event_id = event_id
      new_event_score.reliable = false
      new_event_score.link_to_stats = link_to_stats
      new_event_score.save!
    end
    if event.score_home != last_event_score.score_home || event.score_away != last_event_score.score_away
      logger.info "Found a goal stat for event: #{event}"
      eg = ReportedScore.from_event(event)
      eg.event_id = event_id
      eg.link_to_stats = link_to_stats
      eg.reliable = true
      total_score = event.score_home + event.score_away
      odds = webdriver_handler.get_odds_for_next_team_to_score(event.link, total_score)
      unless odds.nil?
        eg.odds_home_to_score_next = odds[:home]
        eg.odds_away_to_score_next = odds[:away]
      end
      eg.save!
    end
  rescue StandardError => err
    logger.error err.message
    err.backtrace.each { |line| logger.error line }
  ensure
    webdriver_handler.quit_driver
  end

  def self.logger
    @logger ||= DoubleLogger.new('reported_score_updater_worker')
  end

  def self.webdriver_handler
    @webdriver_handler ||= WebdriverHandler.new(logger)
  end

  private_class_method :logger, :webdriver_handler
end