class AddLinkedCandidateToCandidate < ActiveRecord::Migration
  def self.up
    add_column :candidates, :linked_candidate_id, :integer
  end

  def self.down
    remove_column :candidates, :linked_candidate_id
  end
end
