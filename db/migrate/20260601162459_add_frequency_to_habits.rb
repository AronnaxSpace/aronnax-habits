class AddFrequencyToHabits < ActiveRecord::Migration[8.1]
  def change
    add_column :habits, :frequency, :integer, null: false, default: 0
  end
end
