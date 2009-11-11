class RemoveBallotIdFromVote < ActiveRecord::Migration
  def self.up
    remove_index :votes, :column => [ :ballot_id, :candidate_id ]
    remove_column :votes, :ballot_id
  end

  def self.down
    add_column :votes, :ballot_id, :integer
    add_index :votes, [ :ballot_id, :candidate_id ], :unique => true
    say_with_time "Assigning votes directly to ballots..." do
      connection.execute(
        "UPDATE votes AS v, sections AS s " +
        "SET v.ballot_id = s.ballot_id " +
        "WHERE v.section_id = s.id"
      )
    end
  end
end

