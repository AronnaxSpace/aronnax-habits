class CreateHabitEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :habit_entries, id: :uuid do |t|
      t.belongs_to :habit, null: false, foreign_key: true, type: :uuid
      t.date :date, null: false
      t.boolean :completed, null: false, default: false
      t.text :note

      t.timestamps
    end
  end
end
