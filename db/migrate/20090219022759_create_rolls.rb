class CreateRolls < ActiveRecord::Migration
  def self.up
    create_table :rolls do |t|
      t.integer :election_id, :null => false
      t.string :name, :null => false

      t.timestamps
    end
    add_index :rolls, [:election_id, :name], :null => false
    create_table :rolls_users, :id => false do |t|
      t.integer :roll_id, :null => false
      t.integer :user_id, :null => false
    end
    add_index :rolls_users, [:roll_id, :user_id], :unique => true
    add_column :races, :roll_id, :integer
    Race.find(:all).each do |race|
      say "Creating roll for #{race.name}."
      race.roll = race.election.rolls.create( :name => race.name )
      race.save
    end
    execute( "INSERT INTO rolls_users (roll_id, user_id) " +
            "SELECT rolls.id, voters.user_id " +
            "FROM rolls INNER JOIN races INNER JOIN voters " +
            "WHERE rolls.id=races.roll_id AND races.id=voters.race_id" )
    change_column :races, :roll_id, :integer, :null => false
    drop_table :voters
  end

  def self.down
    create_table :voters do |t|
      t.integer :user_id
      t.integer :race_id
      t.timestamps
    end
    add_index :voters, [ :user_id, :race_id ], :unique => true
    execute "INSERT INTO voters (race_id, user_id) " +
            "SELECT races.id, rolls_users.user_id " +
            "FROM races INNER JOIN rolls INNER JOIN rolls_users " +
            "WHERE races.roll_id=rolls.id AND rolls.id=rolls_users.roll_id"
    remove_column :races, :roll_id
    drop_table :rolls_users
    drop_table :rolls
  end
end

