class AddWeekStartsOnToProfile < ActiveRecord::Migration[8.1]
  def change
    add_column :profiles, :week_starts_on, :integer, default: 0, null: false
  end
end
