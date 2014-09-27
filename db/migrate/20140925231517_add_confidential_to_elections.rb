class AddConfidentialToElections < ActiveRecord::Migration
  def change
    add_column :elections, :confidential, :boolean, null: false, default: false
  end
end
