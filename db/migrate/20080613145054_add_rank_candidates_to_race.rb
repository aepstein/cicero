class AddRankCandidatesToRace < ActiveRecord::Migration
  def self.up
    add_column :races, :is_ranked, :boolean, :default => false
  end

  def self.down
    remove_column :races, :is_ranked
  end
end
