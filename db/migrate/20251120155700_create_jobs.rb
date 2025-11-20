class CreateJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :jobs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description, null: false
      t.decimal :budget, precision: 10, scale: 2
      t.string :location, null: false
      t.string :status, default: 'open'
      t.references :assigned_provider, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :jobs, :status
    add_index :jobs, :created_at
  end
end
