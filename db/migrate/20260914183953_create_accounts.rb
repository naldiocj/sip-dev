class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :login, null: false
      t.string :email, null: false
      t.string :password_hash
      t.string :verification_token
      t.datetime :verified_at
      t.datetime :locked_at
      t.integer :failed_login_count, default: 0
      t.datetime :last_login_at
      t.string :session_token
      t.timestamps
    end

    add_index :accounts, :login, unique: true
    add_index :accounts, :email, unique: true
    add_index :accounts, :verification_token
  end
end
