class AddOmniauthAndAronnaxTokensToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :aronnax_access_token, :string
    add_column :users, :aronnax_refresh_token, :string
    add_column :users, :aronnax_expires_at, :datetime

    add_index :users, [ :provider, :uid ], unique: true
  end
end
