class AddContactToElection < ActiveRecord::Migration
  def self.up
    add_column :elections, :contact_name, :string
    add_column :elections, :contact_email, :string
    add_column :elections, :contact_info, :string
  end

  def self.down
    remove_column :elections, :contact_email
    remove_column :elections, :contact_name
    remove_column :elections, :contact_info
  end
end
