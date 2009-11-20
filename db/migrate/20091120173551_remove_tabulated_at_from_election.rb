class RemoveTabulatedAtFromElection < ActiveRecord::Migration
  def self.up
    remove_column :elections, :tabulated_at
  end

  def self.down
    add_column :elections, :tabulated_at, :datetime
  end
end
