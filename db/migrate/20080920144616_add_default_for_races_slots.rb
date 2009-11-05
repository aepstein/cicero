class AddDefaultForRacesSlots < ActiveRecord::Migration
  def self.up
    change_column :races, :slots, :integer, { :null => false, :default => 1 }
  end

  def self.down
    change_column :races, :slots, :integer, { :null => true, :default => nil }
  end
end
