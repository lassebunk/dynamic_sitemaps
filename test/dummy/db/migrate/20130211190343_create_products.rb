class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.boolean :featured, default: false
      t.string :slug

      t.timestamps
    end
  end
end
