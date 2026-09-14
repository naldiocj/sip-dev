class CreatePersonParentalRelations < ActiveRecord::Migration[8.0]
  def change
    create_table :person_parental_relations, id: :uuid do |t|
      t.references :person, null: false, foreign_key: { to_table: :people }, type: :uuid
      t.references :parent, null: false, foreign_key: { to_table: :people }, type: :uuid
      t.string :relation_type, null: false

      t.timestamps
    end

    add_index :person_parental_relations, [ :person_id, :parent_id ], unique: true
  end
end
