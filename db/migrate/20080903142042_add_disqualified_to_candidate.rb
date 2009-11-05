class AddDisqualifiedToCandidate < ActiveRecord::Migration
  def self.up
    add_column :candidates, :disqualified, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :candidates, :disqualified
  end
end
