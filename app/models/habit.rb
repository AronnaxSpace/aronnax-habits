class Habit < ApplicationRecord
  # associations
  belongs_to :user

  # validations
  validates :name, presence: true
  validates :start_date, presence: true
end
