class CreateEvidences < ActiveRecord::Migration[8.0]
  def change
    create_table :evidences do |t|
      t.integer :process_id
      t.string :evidence_type
      t.string :descricao
      t.integer :collector_id
      t.datetime :collected_at

      t.timestamps
    end
  end
end
