class CreateTeamScoredNextType < ActiveRecord::Migration[5.2]
  def up
    execute "
      CREATE TYPE team_scored_next AS ENUM ('yes', 'no', 'error');
      ALTER TABLE reported_events ADD COLUMN losing_team_scored_next team_scored_next;
    "
  end

  def down
    execute "DROP TYPE team_scored_next;"
    remove_column :reported_events, :losing_team_scored_next
  end
end
