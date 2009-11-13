class RemoveCreatedAtFromSection < ActiveRecord::Migration
  def self.up
    remove_column :sections, :created_at
  end

  def self.down
    add_column :sections, :created_at, :datetime
  end
end
