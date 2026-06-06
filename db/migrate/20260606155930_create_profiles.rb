class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles, id: :uuid do |t|
      t.belongs_to :user, null: false, foreign_key: true, type: :uuid
      t.string :nickname, null: false
      t.integer :language, null: false, default: 0

      t.timestamps
    end

    add_index :profiles, :nickname, unique: true
  end
end
