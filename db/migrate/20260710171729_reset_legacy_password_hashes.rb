class ResetLegacyPasswordHashes < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE users SET encrypted_password = '' WHERE encrypted_password != ''"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
