class RemoveLinkedCandidateIdFromCandidate < ActiveRecord::Migration
  def self.up
    remove_column :candidates, :linked_candidate_id
  end

  def self.down
    add_column :candidates, :linked_candidate_id, :integer
  end
end
