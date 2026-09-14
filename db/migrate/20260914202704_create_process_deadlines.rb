class CreateProcessDeadlines < ActiveRecord::Migration[8.0]
  def change
    create_table :process_deadlines, id: :uuid do |t|
      t.references :process, null: false, foreign_key: { to_table: :processes }, type: :uuid
      t.string :deadline_type, null: false
      t.datetime :start_at, null: false
      t.datetime :due_at, null: false
      t.datetime :completed_at
      t.string :status, null: false, default: "EM_CURSO"
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :process_deadlines, [ :process_id, :deadline_type ]
  end
end
