class HabitEntry < ApplicationRecord
  # associations
  belongs_to :habit

  # validations
  validates :completed, inclusion: { in: [ true, false ] }
  validates :date, presence: true
  validates :date, comparison: { less_than_or_equal_to: -> { Date.current } }, allow_blank: true
  validates :habit_id, uniqueness: { scope: :date }
end
