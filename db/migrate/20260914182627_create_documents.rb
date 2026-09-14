class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.integer :process_id
      t.integer :document_type_id
      t.string :title
      t.text :description
      t.string :status
      t.integer :uploader_id

      t.timestamps
    end
  end
end
