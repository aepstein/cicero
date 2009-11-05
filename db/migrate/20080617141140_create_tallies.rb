class CreateTallies < ActiveRecord::Migration
  def self.up
    create_table :tallies do |t|
      t.integer :round_id
      t.integer :candidate_id
      t.integer :tally

      t.timestamps
    end
  end

  def self.down
    drop_table :tallies
  end
end
