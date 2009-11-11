class AddSectionIdToVote < ActiveRecord::Migration
  def self.up
    add_column :votes, :section_id, :integer
    add_index :votes, [ :section_id, :candidate_id ], :unique => true
    say_with_time "Assigning votes to sections..." do
      connection.execute(
        "UPDATE candidates AS c, votes AS v, sections AS s " +
        "SET v.section_id = s.id " +
        "WHERE v.candidate_id = c.id AND c.race_id = s.race_id AND v.ballot_id = s.ballot_id"
      )
    end
  end

  def self.down
    remove_index :votes, :column => [ :section_id, :candidate_id ]
    remove_column :votes, :section_id
  end
end

