class AddEliminatedToCandidate < ActiveRecord::Migration
  def self.up
    add_column :candidates, :eliminated, :boolean, { :default => false, :null => false }
  end

  def self.down
    remove_column :candidates, :eliminated
  end
end
