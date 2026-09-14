class CreateProcessStateTransitions < ActiveRecord::Migration[8.0]
  def change
    create_table :process_state_transitions do |t|
      t.references :from_state, null: false, foreign_key: { to_table: :process_states }, type: :integer
      t.references :to_state, null: false, foreign_key: { to_table: :process_states }, type: :integer
      t.string :action_code, null: false
      t.string :description
      t.boolean :requires_reason, null: false, default: false
      t.boolean :requires_destination, null: false, default: false
      t.boolean :requires_responsible, null: false, default: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :process_state_transitions, [ :from_state_id, :to_state_id, :action_code ], unique: true
  end
end
