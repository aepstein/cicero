class AddCastAtToBallot < ActiveRecord::Migration
  def self.up
    add_column :ballots, :cast_at, :datetime
  end

  def self.down
    remove_column :ballots, :cast_at
  end
end
