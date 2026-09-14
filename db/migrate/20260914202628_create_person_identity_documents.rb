class CreatePersonIdentityDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :person_identity_documents, id: :uuid do |t|
      t.references :person, null: false, type: :uuid
      t.string :document_type, null: false
      t.string :document_number, null: false
      t.date :issued_at
      t.date :expires_at
      t.string :issuing_authority
      t.boolean :is_primary, null: false, default: false

      t.timestamps
    end

    add_index :person_identity_documents, [ :person_id, :document_number ], unique: true
  end
end
