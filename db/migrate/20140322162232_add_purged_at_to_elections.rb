class AddPurgedAtToElections < ActiveRecord::Migration
  def change
    add_column :elections, :purged_at, :datetime
  end
end
