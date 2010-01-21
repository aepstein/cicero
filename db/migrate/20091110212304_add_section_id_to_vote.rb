class AddSectionIdToVote < ActiveRecord::Migration
  def self.up
    add_column :votes, :section_id, :integer
    add_index :votes, [ :section_id, :candidate_id ], :unique => true
    say_with_time "Assigning votes to sections..." do
      connection.execute(
        "UPDATE votes SET section_id = (SELECT sections.id FROM sections INNER JOIN candidates " +
        "WHERE sections.race_id = candidates.race_id AND " +
        "candidates.id = votes.candidate_id AND " +
        "sections.ballot_id = votes.ballot_id)"
      )
    end
  end

  def self.down
    remove_index :votes, :column => [ :section_id, :candidate_id ]
    remove_column :votes, :section_id
  end
end

