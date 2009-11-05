class AddStatementToCandidate < ActiveRecord::Migration
  def self.up
    add_column :candidates, :statement, :text
  end

  def self.down
    remove_column :candidates, :statement
  end
end
