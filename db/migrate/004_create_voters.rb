class CreateVoters < ActiveRecord::Migration
  def self.up
    create_table :voters do |t|
      t.integer :user_id
      t.integer :race_id
      t.timestamps
    end
    add_index :voters, [ :user_id, :race_id ], :unique => true
  end

  def self.down
    drop_table :voters
  end
end
