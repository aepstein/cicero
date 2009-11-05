class ChangeVerifyMessageInElection < ActiveRecord::Migration
  def self.up
    change_column( :elections, :verify_message, :text, :limit => 4096 )
  end

  def self.down
    change_column( :elections, :verify_message, :string )
  end
end
