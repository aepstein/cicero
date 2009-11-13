class RemoveCastAtUpdatedAtFromBallot < ActiveRecord::Migration
  def self.up
    remove_column :ballots, :cast_at
    remove_column :ballots, :updated_at
  end

  def self.down
    add_column :ballots, :updated_at, :datetime
    add_column :ballots, :cast_at, :datetime
  end
end
