class ChangeContactInfoInElection < ActiveRecord::Migration
  def self.up
    change_column( :elections, :contact_info, :text, :limit => 4096 )
  end

  def self.down
    change_column( :elections, :contact_info, :string )
  end
end
