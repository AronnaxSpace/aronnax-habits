class CreateHabits < ActiveRecord::Migration[8.1]
  def change
    create_table :habits, id: :uuid do |t|
      t.string :name
      t.text :description
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
