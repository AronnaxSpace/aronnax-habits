class Profile < ApplicationRecord
  enum :language, en: 0, uk: 1
  enum :week_starts_on, sunday: 0, monday: 1

  # associations
  belongs_to :user

  # validations
  validates :nickname, presence: true, uniqueness: true

  def self.human_enum_name(enum_name, enum_value)
    I18n.t(
      "activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value}"
    )
  end
end
