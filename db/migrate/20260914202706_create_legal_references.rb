class CreateLegalReferences < ActiveRecord::Migration[8.0]
  def change
    create_table :legal_references do |t|
      t.string :code
      t.string :diploma
      t.string :artigo
      t.string :numero
      t.string :alinea
      t.text :descricao
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :legal_references, :code
  end
end
