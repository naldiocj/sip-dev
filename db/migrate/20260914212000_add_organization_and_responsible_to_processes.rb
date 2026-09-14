class AddOrganizationAndResponsibleToProcesses < ActiveRecord::Migration[8.0]
  def change
    add_reference :processes, :organizacao, foreign_key: { to_table: :organizations }, null: true
    add_reference :processes, :responsavel, foreign_key: { to_table: :users }, null: true
  end
end
