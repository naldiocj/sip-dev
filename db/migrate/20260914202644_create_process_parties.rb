class CreateProcessParties < ActiveRecord::Migration[8.0]
  def change
    create_table :process_parties, id: :uuid do |t|
      t.references :process, null: false, foreign_key: { to_table: :processes }, type: :uuid
      t.references :person, null: false, foreign_key: { to_table: :people }, type: :uuid
      t.references :party_type, null: false, foreign_key: { to_table: :party_types }
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.string :status, null: false, default: "ATIVO"
      t.text :observacao
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :process_parties, [ :process_id, :person_id, :party_type_id ], unique: true
  end
end
