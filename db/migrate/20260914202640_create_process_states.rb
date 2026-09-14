class CreateProcessStates < ActiveRecord::Migration[8.0]
  def change
    create_table :process_states do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.text :description
      t.boolean :terminal, null: false, default: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :process_states, :code, unique: true
  end
end
