class CreatePersonAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :person_addresses, id: :uuid do |t|
      t.references :person, null: false, foreign_key: { to_table: :people }, type: :uuid
      t.references :address, null: false, foreign_key: { to_table: :addresses }, type: :uuid
      t.string :address_type, null: false
      t.boolean :is_primary, null: false, default: false
      t.datetime :valid_from
      t.datetime :valid_to

      t.timestamps
    end

    add_index :person_addresses, [ :person_id, :address_id ], unique: true
  end
end
