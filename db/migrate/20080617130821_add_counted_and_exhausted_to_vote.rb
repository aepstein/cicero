class AddCountedAndExhaustedToVote < ActiveRecord::Migration
  def self.up
    add_column :votes, :distributed, :integer, { :default => nil }
    add_column :votes, :exhausted, :integer, { :default => nil }
  end

  def self.down
    remove_column :votes, :distributed
    remove_column :votes, :exhausted
  end
end
