class CreateDiligences < ActiveRecord::Migration[8.0]
  def change
    create_table :diligences do |t|
      t.integer :process_id
      t.string :diligencia_type
      t.string :descricao
      t.string :estado
      t.integer :responsavel_id
      t.date :data_prevista
      t.datetime :data_real

      t.timestamps
    end
  end
end
