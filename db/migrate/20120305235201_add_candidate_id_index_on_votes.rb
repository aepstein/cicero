class AddCandidateIdIndexOnVotes < ActiveRecord::Migration
  def up
    add_index :votes, :candidate_id
  end

  def down
    remove_index :votes, :candidate_id
  end
end

