class CreateConfidentialityLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :confidentiality_levels do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    add_index :confidentiality_levels, :code, unique: true
  end
end
