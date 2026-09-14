class AddDiligenciaTypeRefToDiligences < ActiveRecord::Migration[8.0]
  def change
    add_reference :diligences, :diligencia_type, foreign_key: { to_table: :diligence_types }, null: true
  end
end
