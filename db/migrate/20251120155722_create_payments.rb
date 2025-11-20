class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.references :subscription, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :payment_method, null: false
      t.string :status, default: 'pending'
      t.string :transaction_id

      t.timestamps
    end
    add_index :payments, :status
    add_index :payments, :transaction_id
  end
end
