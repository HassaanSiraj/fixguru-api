class CreateBids < ActiveRecord::Migration[7.1]
  def change
    create_table :bids do |t|
      t.references :job, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :proposed_cost, precision: 10, scale: 2, null: false
      t.text :proposal_message, null: false
      t.string :estimated_time
      t.string :status, default: 'pending'

      t.timestamps
    end
    add_index :bids, [:job_id, :user_id], unique: true
    add_index :bids, :status
  end
end
