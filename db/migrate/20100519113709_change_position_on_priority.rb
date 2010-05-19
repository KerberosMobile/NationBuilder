class ChangePositionOnPriority < ActiveRecord::Migration
  def self.up
    change_column :priorities, :position, :integer, :default => 0, :null => true
  end

  def self.down
    change_column :priorities, :position, :integer, :default => 0, :null => false
  end
end
