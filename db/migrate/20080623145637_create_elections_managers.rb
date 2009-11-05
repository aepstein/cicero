class CreateElectionsManagers < ActiveRecord::Migration
  def self.up
    create_table( :elections_managers,
                  :id => false,
                  :primary_key => ['election_id','user_id'] ) do |t|
      t.integer :election_id, :null => false
      t.integer :user_id, :null => false
    end
  end

  def self.down
    drop_table :elections_managers
  end
end
