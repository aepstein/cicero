class ConvertCandidatesToCarrierwave < ActiveRecord::Migration
  def up
    remove_column :candidates, :picture_updated_at
    remove_column :candidates, :picture_file_size
    remove_column :candidates, :picture_content_type
    rename_column :candidates, :picture_file_name, :picture
  end

  def down
    raise IrreversibleMigration
  end
end

