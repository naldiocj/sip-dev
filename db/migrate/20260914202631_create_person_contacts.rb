class CreatePersonContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :person_contacts, id: :uuid do |t|
      t.references :person, null: false, foreign_key: { to_table: :people }, type: :uuid
      t.string :contact_type, null: false
      t.string :contact_value, null: false
      t.boolean :is_primary, null: false, default: false
      t.datetime :verified_at

      t.timestamps
    end

    add_index :person_contacts, [ :person_id, :contact_type, :contact_value ], unique: true
  end
end
