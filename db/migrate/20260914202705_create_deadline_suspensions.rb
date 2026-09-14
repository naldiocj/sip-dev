class CreateDeadlineSuspensions < ActiveRecord::Migration[8.0]
  def change
    create_table :deadline_suspensions, id: :uuid do |t|
      t.references :process_deadline, null: false, foreign_key: { to_table: :process_deadlines }, type: :uuid
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.text :reason
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
