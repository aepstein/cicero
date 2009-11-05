class CreateRounds < ActiveRecord::Migration
  def self.up
    create_table :rounds do |t|
      t.integer :race_id
      t.integer :position

      t.timestamps
    end
    add_index :rounds, [ :race_id, :position ], :unique => true
  end

  def self.down
    drop_table :rounds
  end
end
