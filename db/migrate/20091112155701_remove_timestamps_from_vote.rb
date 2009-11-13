class RemoveTimestampsFromVote < ActiveRecord::Migration
  def self.up
    remove_column :votes, :created_at
    remove_column :votes, :updated_at
  end

  def self.down
    add_column :votes, :updated_at, :datetime
    add_column :votes, :created_at, :datetime
  end
end
