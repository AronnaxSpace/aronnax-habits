class Habit < ApplicationRecord
  # associations
  belongs_to :user

  # validations
  validates :name, presence: true
end
