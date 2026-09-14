class CreatePeople < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :people, id: :uuid do |t|
      t.string :nome_completo, null: false
      t.string :nome_proprio
      t.string :nome_meio
      t.string :apelido
      t.date :data_nascimento

      t.timestamps
    end

    add_index :people, :nome_completo
  end
end
