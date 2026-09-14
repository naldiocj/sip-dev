class CreateDiligenceTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :diligence_types do |t|
      t.string :name
      t.string :code
      t.string :description

      t.timestamps
    end
  end
end
