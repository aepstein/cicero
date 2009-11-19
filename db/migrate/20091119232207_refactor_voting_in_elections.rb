class RefactorVotingInElections < ActiveRecord::Migration
  def self.up
    rename_column :elections, :voting_starts_at, :starts_at
    rename_column :elections, :voting_ends_at, :ends_at
  end

  def self.down
    rename_column :elections, :starts_at, :voting_starts_at
    rename_column :elections, :ends_at, :voting_ends_at
  end
end

