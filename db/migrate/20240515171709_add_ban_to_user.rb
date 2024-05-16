class AddBanToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :ban, :boolean, :default => false
  end
end
