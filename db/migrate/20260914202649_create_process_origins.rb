class CreateProcessOrigins < ActiveRecord::Migration[8.0]
  def change
    create_table :process_origins do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    add_index :process_origins, :code, unique: true
  end
end
