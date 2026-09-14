class CreateProcessNatures < ActiveRecord::Migration[8.0]
  def change
    create_table :process_natures do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    add_index :process_natures, :code, unique: true
  end
end
