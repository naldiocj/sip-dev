class CreateProcessClosures < ActiveRecord::Migration[8.0]
  def change
    create_table :process_closures, id: :uuid do |t|
      t.references :process, null: false, foreign_key: { to_table: :processes }, type: :uuid
      t.string :closure_type, null: false
      t.datetime :closed_at, null: false
      t.references :closed_by, null: false, foreign_key: { to_table: :users }
      t.text :reason
      t.text :notes

      t.timestamps
    end
  end
end
