class AddStartDateAndEndDateToHabits < ActiveRecord::Migration[8.1]
  def change
    add_column :habits, :start_date, :date
    add_column :habits, :end_date, :date
  end
end
