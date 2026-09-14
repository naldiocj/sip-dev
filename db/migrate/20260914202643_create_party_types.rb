class CreatePartyTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :party_types do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    add_index :party_types, :code, unique: true
  end
end
