class DropRounds < ActiveRecord::Migration
  def self.up
    remove_index :rounds, [ :race_id, :position ]
    drop_table :rounds
  end

  def self.down
    create_table :rounds do |t|
      t.integer :race_id
      t.integer :position

      t.timestamps
    end
    add_index :rounds, [ :race_id, :position ], :unique => true
  end
end

