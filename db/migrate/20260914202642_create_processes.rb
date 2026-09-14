class CreateProcesses < ActiveRecord::Migration[8.0]
  def change
    create_table :processes, id: :uuid do |t|
      t.uuid :uuid, null: false
      t.string :numero, null: false
      t.integer :ano, null: false
      t.string :numero_mp
      t.string :titulo, null: false
      t.text :resumo
      t.references :process_type, null: false
      t.references :process_nature, null: false
      t.references :process_origin, null: false
      t.references :process_priority, null: false
      t.references :confidentiality_level, null: false
      t.references :process_state, null: false
      t.datetime :data_entrada, null: false
      t.datetime :data_registo, null: false
      t.references :created_by, null: false
      t.references :updated_by, null: false

      t.timestamps
    end

    add_index :processes, :uuid, unique: true
    add_index :processes, [ :numero, :ano ], unique: true
    add_index :processes, :numero
    add_index :processes, :titulo
  end
end
