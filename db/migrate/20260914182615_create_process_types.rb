class CreateProcessTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :process_types do |t|
      t.string :name
      t.string :code
      t.string :description

      t.timestamps
    end
  end
end
