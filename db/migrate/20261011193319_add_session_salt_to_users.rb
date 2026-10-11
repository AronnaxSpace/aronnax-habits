class AddSessionSaltToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :session_salt, :string
  end
end
