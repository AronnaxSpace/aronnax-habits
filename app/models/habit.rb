class Habit < ApplicationRecord
  enum :frequency, daily: 0, weekly: 1, twice_a_week: 2, thrice_a_week: 3
  FREQUENCY_TARGETS = {
    "daily" => 7,
    "weekly" => 1,
    "twice_a_week" => 2,
    "thrice_a_week" => 3
  }.freeze

  # associations
  belongs_to :user
  has_many :entries, class_name: "HabitEntry"

  # validations
  validates :name, presence: true
  validates :start_date, presence: true

  def active_on?(date)
    start_date <= date && (end_date.nil? || end_date >= date)
  end

  def self.human_enum_name(enum_name, enum_value)
    I18n.t(
      "activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value}"
    )
  end

  def frequency_label
    self.class.human_enum_name(:frequency, frequency)
  end

  def weekly_target(active_days_count = 7)
    [ FREQUENCY_TARGETS.fetch(frequency), active_days_count ].min
  end
end
