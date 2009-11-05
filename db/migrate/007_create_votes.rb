class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.integer :ballot_id
      t.integer :candidate_id
      t.integer :rank

      t.timestamps
    end
    add_index :votes, [ :ballot_id, :candidate_id ], :unique => true
  end

  def self.down
    drop_table :votes
  end
end
