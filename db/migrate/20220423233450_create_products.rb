class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.integer :quantity, null: false
      t.integer :price, null: false
      t.references :seller, null: false, foreign_key: {to_table: :users}

      t.timestamps
    end
    add_index :products, :price
  end
end
