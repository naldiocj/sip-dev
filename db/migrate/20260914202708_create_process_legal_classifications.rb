class CreateProcessLegalClassifications < ActiveRecord::Migration[8.0]
  def change
    create_table :process_legal_classifications, id: :uuid do |t|
      t.references :process, null: false, foreign_key: { to_table: :processes }, type: :uuid
      t.references :legal_reference, null: false, foreign_key: { to_table: :legal_references }
      t.boolean :primary, null: false, default: false
      t.text :observacao
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
