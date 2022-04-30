class CreatePurchases < ActiveRecord::Migration[7.0]
  def change
    create_table :purchases do |t|
      t.references :product
      t.string :product_name, null: false
      t.integer :price, null: false
      t.integer :quantity, null: false
      t.references :seller, null: false, foreign_key: {to_table: :users}
      t.references :buyer, null: false, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
