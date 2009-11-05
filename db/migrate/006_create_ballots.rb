class CreateBallots < ActiveRecord::Migration
  def self.up
    create_table :ballots do |t|
      t.integer :election_id, :nil => false
      t.integer :user_id, :nil => false

      t.timestamps
    end
    add_index :ballots, [ :user_id, :election_id ], :unique => true
  end

  def self.down
    drop_table :ballots
  end
end
