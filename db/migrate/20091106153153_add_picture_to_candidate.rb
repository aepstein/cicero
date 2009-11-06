class AddPictureToCandidate < ActiveRecord::Migration
  def self.up
    add_column :candidates, :picture_file_name, :string
    add_column :candidates, :picture_content_type, :string
    add_column :candidates, :picture_file_size, :integer
    add_column :candidates, :picture_updated_at, :datetime
  end

  def self.down
    remove_column :candidates, :picture_updated_at
    remove_column :candidates, :picture_file_size
    remove_column :candidates, :picture_content_type
    remove_column :candidates, :picture_file_name
  end
end