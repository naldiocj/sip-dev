class CreateMandates < ActiveRecord::Migration[8.0]
  def change
    create_table :mandates do |t|
      t.integer :process_id
      t.string :mandate_type
      t.integer :emissor_id
      t.string :destino
      t.text :descricao
      t.string :estado
      t.date :data_emissao
      t.date :data_prazo

      t.timestamps
    end
  end
end
