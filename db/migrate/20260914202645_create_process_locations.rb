class CreateProcessLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :process_locations, id: :uuid do |t|
      t.references :process, null: false, foreign_key: { to_table: :processes }, type: :uuid
      t.references :organization, null: false, foreign_key: { to_table: :organizations }
      t.references :user, foreign_key: { to_table: :users }
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.text :reason
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :process_locations, [ :process_id, :started_at ]
  end
end
