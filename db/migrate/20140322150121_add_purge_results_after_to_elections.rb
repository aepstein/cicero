class AddPurgeResultsAfterToElections < ActiveRecord::Migration
  def up
    add_column :elections, :purge_results_after, :date
    execute <<-SQL
      UPDATE elections SET purge_results_after = DATE_ADD( results_available_at, INTERVAL 2 YEAR );
    SQL
    change_column :elections, :purge_results_after, :date, null: false
    add_index :elections, :purge_results_after
  end
  
  def down
    remove_column :elections, :purge_results_after
  end
end
