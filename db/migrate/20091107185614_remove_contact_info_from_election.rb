class RemoveContactInfoFromElection < ActiveRecord::Migration
  def self.up
    remove_column :elections, :contact_info
  end

  def self.down
    add_column :elections, :contact_info, :text
  end
end
