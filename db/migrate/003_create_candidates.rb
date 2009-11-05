class CreateCandidates < ActiveRecord::Migration
  def self.up
    create_table :candidates do |t|
      t.integer :race_id, :nil => false
      t.string :name, :nil => false

      t.timestamps
    end
    add_index :candidates, [ :race_id, :name ], :unique => true
  end

  def self.down
    drop_table :candidates
  end
end
