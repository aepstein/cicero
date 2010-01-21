class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.references :ballot, :null => false
      t.references :race, :null => false
    end

    add_index :sections, [ :ballot_id, :race_id ], :unique => true

    say_with_time "Creating sections for existing ballots..." do
      connection.execute(
        "INSERT INTO sections ( ballot_id, race_id ) " +
        "SELECT ballot_id, race_id FROM votes INNER JOIN candidates " +
        "ON votes.candidate_id = candidates.id " +
        "GROUP BY votes.ballot_id, candidates.race_id"
      )
    end
  end

  def self.down
    drop_table :sections
  end
end

