class Habit < ApplicationRecord
  # associations
  belongs_to :user
  has_many :entries, class_name: "HabitEntry"

  # validations
  validates :name, presence: true
  validates :start_date, presence: true

  def active_on?(date)
    start_date <= date && (end_date.nil? || end_date >= date)
  end
end
