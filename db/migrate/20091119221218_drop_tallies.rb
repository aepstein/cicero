class DropTallies < ActiveRecord::Migration
  def self.up
    drop_table :tallies
  end

  def self.down
    create_table :tallies do |t|
      t.integer :round_id
      t.integer :candidate_id
      t.integer :tally

      t.timestamps
    end
  end
end

