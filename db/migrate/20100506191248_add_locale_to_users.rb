class AddLocaleToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :locale, :string, :limit => 5, :default => 'en'
  end

  def self.down
    remove_column :users, :locale
  end
end
