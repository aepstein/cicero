class AddResultsAvailableAtToElection < ActiveRecord::Migration
  def self.up
    add_column :elections, :results_available_at, :datetime, { :null => false, :default => '9999-12-12 00:00:01' }
    Election.find(:all).each do |election|
      election.results_available_at = election.voting_ends_at + 1.days
      election.save
    end
  end

  def self.down
    remove_column :elections, :results_available_at
  end
end
