class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.string :conversation_id, null: false
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.text :content, null: false
      t.boolean :read, default: false

      t.timestamps
    end
    add_index :messages, :conversation_id
    add_index :messages, [:sender_id, :receiver_id]
    add_index :messages, :created_at
  end
end
