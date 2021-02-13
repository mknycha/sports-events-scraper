# frozen_string_literal: true

require 'spec_helper'

describe WebScraper do
  let(:web_scraper) { described_class.new(Logger.new(STDOUT)) }
  let(:link) do
    'https://sports.williamhill.com/betting/en-gb/football/OB_EV14932257/liverpool-vs-man-city'
  end
  let(:event) do
    Event.new('Liverpool v Man City', '54:06', '1-0', link).tap do |event|
      event.ball_possession = { home: 35, away: 65 }
      event.attacks = { home: 1, away: 0 }
      event.shots_on_target = { home: 1, away: 2 }
      event.shots_off_target = { home: 3, away: 1 }
      event.corners = { home: 1, away: 0 }
    end
  end
  let(:event_id) { 'OB_EV14932257' }
  let(:reported_event) { ReportedEvent.from_event(event) }

  after do
    ReportedEvent.destroy_all
  end

  describe '#save_and_report_event' do
    before do
      stub_const('EventConditionChecker::ATTRIBUTES_COEFFICIENTS', stubbed_attrs)
      web_scraper.send(:setup_events_table)
    end
    let(:stubbed_attrs) do
      {
        possession: 0.017,
        attacks: 0.13,
        shots_off_target: 0.15,
        corners: 0.1,
        team_at_home: 0.1
      }
    end

    it 'saves an event to the database' do
      expect { web_scraper.send(:save_and_report_event, event, event_id) }
        .to change(ReportedEvent, :count).by(1)
    end
  end

  describe '#event_second_half_started?' do
    let(:webdriver_handler) { double(:webdriver_handler) }
    let(:link_to_stats) { 'https://scoreboardslauncher.williamhill.com/scoreboards/events/OB_EV14932257/launch?lang=en-gb&showSuggestions=true' }

    context 'event before second half' do
      before do
        allow(webdriver_handler).to receive(:link_to_event_stats_page).with(link).and_return(link_to_stats)
        allow(webdriver_handler).to receive(:second_half_available?).with(link_to_stats).and_return(false)
      end

      it 'returns false' do
        expect(webdriver_handler).to receive(:link_to_event_stats_page).with(link)
        expect(webdriver_handler).to receive(:second_half_available?).with(link_to_stats)
        expect(web_scraper.send(:event_second_half_started?, event, webdriver_handler)).to eq(false)
      end
    end

    context 'event with second half started' do
      before do
        allow(webdriver_handler).to receive(:link_to_event_stats_page).with(link).and_return(link_to_stats)
        allow(webdriver_handler).to receive(:second_half_available?).with(link_to_stats).and_return(true)
      end

      it 'returns true' do
        expect(webdriver_handler).to receive(:link_to_event_stats_page).with(link)
        expect(webdriver_handler).to receive(:second_half_available?).with(link_to_stats)
        expect(web_scraper.send(:event_second_half_started?, event, webdriver_handler)).to eq(true)
      end
    end

    context 'event with no link to stats' do
      before do
        allow(webdriver_handler).to receive(:link_to_event_stats_page).with(link).and_return(nil)
      end

      it 'returns false' do
        expect(webdriver_handler).to receive(:link_to_event_stats_page).with(link)
        expect(webdriver_handler).not_to receive(:second_half_available?)
        expect(web_scraper.send(:event_second_half_started?, event, webdriver_handler)).to eq(false)
      end
    end
  end
end
