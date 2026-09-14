class CreateProcessReopenings < ActiveRecord::Migration[8.0]
  def change
    create_table :process_reopenings, id: :uuid do |t|
      t.references :process, null: false, foreign_key: { to_table: :processes }, type: :uuid
      t.datetime :reopened_at, null: false
      t.references :reopened_by, null: false, foreign_key: { to_table: :users }
      t.string :legal_basis
      t.text :reason
      t.text :notes

      t.timestamps
    end
  end
end
