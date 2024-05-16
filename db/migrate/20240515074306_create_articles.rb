class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :description
      t.references :category, null: false,foreign_key: true
      t.references :user,null: false,foreign_key: true
      t.string :status
      t.datetime :discarded_at
      t.boolean :is_discarded,:default => false

      t.timestamps
    end
  end
end
