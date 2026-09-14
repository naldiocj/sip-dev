class CreateProcessAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :process_assignments, id: :uuid do |t|
      t.references :process, null: false, type: :uuid
      t.references :assigned_to_user, null: false
      t.references :assigned_to_organization, null: false
      t.string :assignment_type, null: false
      t.references :assigned_by, null: false
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.text :reason

      t.timestamps
    end

    add_index :process_assignments, [ :process_id, :started_at ]
  end
end
