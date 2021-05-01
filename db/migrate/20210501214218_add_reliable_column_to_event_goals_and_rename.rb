class AddReliableColumnToEventGoalsAndRename < ActiveRecord::Migration[5.2]
  def change
    change_table :event_goals do |t|
      t.boolean :reliable
    end
    rename_table :event_goals, :reported_scores
  end
end
