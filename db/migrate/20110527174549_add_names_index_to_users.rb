class AddNamesIndexToUsers < ActiveRecord::Migration
  def self.up
    add_index :users, [ :last_name, :first_name, :net_id ]
  end

  def self.down
    remove_index :users, [ :last_name, :first_name, :net_id ]
  end
end

