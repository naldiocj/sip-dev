class CreateSipProcesses < ActiveRecord::Migration[8.0]
  def change
    create_table :sip_processes do |t|
      t.string :numero
      t.integer :tipo_id
      t.string :origem
      t.string :estado
      t.string :prioridade
      t.date :prazo
      t.integer :organizacao_id
      t.integer :responsavel_id
      t.integer :criador_id

      t.timestamps
    end
  end
end
