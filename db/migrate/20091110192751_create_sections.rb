class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.references :ballot, :null => false
      t.references :race, :null => false
      t.datetime :created_at
    end

    add_index :sections, [ :ballot_id, :race_id ], :unique => true

    say_with_time "Creating sections for existing ballots..." do
      connection.execute(
        "INSERT INTO sections ( ballot_id, race_id, created_at ) " +
        "SELECT b.id, c.race_id, b.created_at FROM " +
        "ballots AS b, votes AS v, candidates AS c " +
        "WHERE b.id = v.ballot_id AND v.candidate_id = c.id " +
        "GROUP BY c.race_id"
      )
    end
  end

  def self.down
    drop_table :sections
  end
end

