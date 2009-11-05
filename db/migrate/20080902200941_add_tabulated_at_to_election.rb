class AddTabulatedAtToElection < ActiveRecord::Migration
  def self.up
    add_column :elections, :tabulated_at, :datetime
  end

  def self.down
    remove_column :elections, :tabulated_at
  end
end
