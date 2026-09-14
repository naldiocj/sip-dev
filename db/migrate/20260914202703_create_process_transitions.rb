class CreateProcessTransitions < ActiveRecord::Migration[8.0]
  def change
    create_table :process_transitions, id: :uuid do |t|
      t.references :process, null: false, foreign_key: { to_table: :processes }, type: :uuid
      t.references :from_state, foreign_key: { to_table: :process_states }
      t.references :to_state, null: false, foreign_key: { to_table: :process_states }
      t.string :action_code, null: false
      t.references :performed_by, null: false, foreign_key: { to_table: :users }
      t.references :organization, foreign_key: { to_table: :organizations }
      t.text :reason
      t.text :notes

      t.timestamps
    end

    add_index :process_transitions, [ :process_id, :created_at ]
  end
end
