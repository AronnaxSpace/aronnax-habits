class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # associations
  has_one :profile, dependent: :destroy
  has_many :habits, dependent: :destroy

  # callbacks
  after_create :add_profile

  private

  def add_profile
    language = Profile.languages.key?(Current.locale.to_s) ? Current.locale.to_s : "en"
    create_profile(nickname: UniqueNicknameGenerator.generate(email.split("@").first), language: language)
  end
end
