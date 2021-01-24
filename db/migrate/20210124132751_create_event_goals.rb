class CreateEventGoals < ActiveRecord::Migration[5.2]
  def change
    create_table :event_goals do |t|
      t.string :event_id, null: false
      t.string :team_home, null: false
      t.string :team_away, null: false
      t.string :link, null: false
      t.string :link_to_stats
      t.string :reporting_time, null: false
      t.integer :score_home, null: false, default: 0
      t.integer :score_away, null: false, default: 0
      t.integer :ball_possession_home, null: false, default: 0
      t.integer :ball_possession_away, null: false, default: 0
      t.integer :attacks_home, null: false, default: 0
      t.integer :attacks_away, null: false, default: 0
      t.integer :shots_on_target_home, null: false, default: 0
      t.integer :shots_on_target_away, null: false, default: 0
      t.integer :shots_off_target_home, null: false, default: 0
      t.integer :shots_off_target_away, null: false, default: 0
      t.integer :corners_home, null: false, default: 0
      t.integer :corners_away, null: false, default: 0
      t.decimal :odds_home_to_score_next
      t.decimal :odds_away_to_score_next

      t.timestamps
    end
  end
end
