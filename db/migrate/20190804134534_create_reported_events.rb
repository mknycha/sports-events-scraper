class CreateReportedEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :reported_events do |t|
      t.string :event_id, null: false
      t.string :team_home, null: false
      t.string :team_away, null: false
      t.string :link, null: false
      t.string :link_to_stats
      t.string :time, null: false
      t.integer :score_home, null: false, default: 0
      t.integer :score_away, null: false, default: 0
      t.integer :possession_percentage_home, null: false, default: 0
      t.integer :possession_percentage_away, null: false, default: 0
      t.integer :attacks_home, null: false, default: 0
      t.integer :attacks_away, null: false, default: 0
      t.integer :shots_on_target_home, null: false, default: 0
      t.integer :shots_on_target_away, null: false, default: 0
      t.integer :shots_off_target_home, null: false, default: 0
      t.integer :shots_off_target_away, null: false, default: 0
      t.integer :corners_home, null: false, default: 0
      t.integer :corners_away, null: false, default: 0

      t.index :event_id
      t.timestamps
    end
  end
end
