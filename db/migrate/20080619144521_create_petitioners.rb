class CreatePetitioners < ActiveRecord::Migration
  def self.up
    create_table :petitioners do |t|
      t.integer :candidate_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :petitioners
  end
end
