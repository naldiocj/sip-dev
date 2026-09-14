class CreateUserAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :user_assignments do |t|
      t.integer :user_id
      t.integer :organization_id
      t.integer :profile_id
      t.string :role
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
