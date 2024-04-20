class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :name
      t.string :code, null: false
      t.integer :type
      t.integer :amount
      t.integer :status, default: 0
      t.references :merchant, null: false, foreign_key: true

      t.timestamps
    end

    add_index :coupons, :code, unique: true
  end
end
