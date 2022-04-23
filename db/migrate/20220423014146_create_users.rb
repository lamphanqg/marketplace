class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: {unique: true}
      t.string :password_digest, null: false
      t.integer :point, null: false, default: 10_000

      t.timestamps
    end
  end
end
