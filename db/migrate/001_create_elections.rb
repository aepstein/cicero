class CreateElections < ActiveRecord::Migration
  def self.up
    create_table :elections do |t|
      t.string :name
      t.datetime :voting_starts_at
      t.datetime :voting_ends_at

      t.timestamps
    end
  end

  def self.down
    drop_table :elections
  end
end
