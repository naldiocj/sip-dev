class AddDeviseFieldsToAccounts < ActiveRecord::Migration[8.0]
  def change
    # Devise recoverable + rememberable fields
    add_column :accounts, :reset_password_token, :string
    add_column :accounts, :reset_password_sent_at, :datetime
    add_column :accounts, :remember_created_at, :datetime

    # Devise trackable fields
    add_column :accounts, :sign_in_count, :integer, default: 0, null: false
    add_column :accounts, :current_sign_in_at, :datetime
    add_column :accounts, :last_sign_in_at, :datetime
    add_column :accounts, :current_sign_in_ip, :string
    add_column :accounts, :last_sign_in_ip, :string

    add_index :accounts, :reset_password_token, unique: true
  end
end
