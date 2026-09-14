class CreateProfileCapabilities < ActiveRecord::Migration[8.0]
  def change
    create_table :profile_capabilities do |t|
      t.integer :profile_id
      t.integer :capability_id

      t.timestamps
    end
  end
end
