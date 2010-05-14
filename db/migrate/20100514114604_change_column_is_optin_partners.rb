class ChangeColumnIsOptinPartners < ActiveRecord::Migration
  def self.up
    remove_column :partners, :is_optin
    add_column :partners, :is_optin, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :partners, :is_optin
    add_column :partners, :is_optin, :integer, :limit => 2, :default => 0, :null => false
  end
end
