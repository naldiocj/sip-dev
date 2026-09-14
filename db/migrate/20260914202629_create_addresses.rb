class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses, id: :uuid do |t|
      t.string :pais
      t.string :provincia
      t.string :municpio
      t.string :comuna
      t.string :bairro
      t.string :rua
      t.string :numero_porta
      t.string :andar
      t.string :apartamento
      t.text :referencia
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7

      t.timestamps
    end
  end
end
