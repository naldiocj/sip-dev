class CreateProcessAuditEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :process_audit_events, id: :uuid do |t|
      t.references :process, null: false, foreign_key: { to_table: :processes }, type: :uuid
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.string :entity_type
      t.bigint :entity_id
      t.jsonb :before_data
      t.jsonb :after_data
      t.inet :ip_address
      t.text :user_agent

      t.timestamps
    end

    add_index :process_audit_events, [ :process_id, :created_at ]
    add_index :process_audit_events, [ :actor_id, :created_at ]
  end
end
