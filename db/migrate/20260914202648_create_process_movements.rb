class CreateProcessMovements < ActiveRecord::Migration[8.0]
  def change
    create_table :process_movements, id: :uuid do |t|
      t.references :process, null: false, foreign_key: { to_table: :processes }, type: :uuid
      t.string :movement_type, null: false
      t.references :from_organization, foreign_key: { to_table: :organizations }
      t.references :to_organization, foreign_key: { to_table: :organizations }
      t.references :from_user, foreign_key: { to_table: :users }
      t.references :to_user, foreign_key: { to_table: :users }
      t.references :performed_by, null: false, foreign_key: { to_table: :users }
      t.text :reason
      t.text :notes

      t.timestamps
    end

    add_index :process_movements, [ :process_id, :created_at ]
  end
end
