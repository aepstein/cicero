class AddVerifyMessageToElection < ActiveRecord::Migration
  def self.up
    add_column :elections, :verify_message, :string
  end

  def self.down
    remove_column :elections, :verify_message
  end
end
