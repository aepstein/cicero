class CreateRaces < ActiveRecord::Migration
  def self.up
    create_table :races do |t|
      t.integer :election_id
      t.string :name
      t.integer :slots

      t.timestamps
    end
    add_index :races, [ :election_id, :name ], :unique => true
  end

  def self.down
    drop_table :races
  end
end
