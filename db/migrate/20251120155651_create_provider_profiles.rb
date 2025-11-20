class CreateProviderProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :provider_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :full_name
      t.string :cnic_number
      t.text :skills
      t.text :experience
      t.text :service_areas
      t.string :verification_status, default: 'pending'

      t.timestamps
    end
    add_index :provider_profiles, :verification_status
  end
end
