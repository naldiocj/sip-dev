class AddShortNameToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :short_name, :string
  end
end
