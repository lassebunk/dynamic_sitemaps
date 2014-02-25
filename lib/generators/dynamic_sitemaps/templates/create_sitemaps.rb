class CreateSitemaps < ActiveRecord::Migration
  def change
    create_table :sitemaps do |t|
      t.string :path, null: false
      t.text :content
    end

    add_index :sitemaps, :path, unique: true
  end
end
