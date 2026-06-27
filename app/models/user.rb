class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :aronnax ]

  # associations
  has_one :profile, dependent: :destroy
  has_many :habits, dependent: :destroy

  # callbacks
  after_create :add_profile

  def self.from_omniauth(auth)
    token_attrs = {
      aronnax_access_token: auth.credentials.token,
      aronnax_refresh_token: auth.credentials.refresh_token,
      aronnax_expires_at: auth.credentials.expires_at && Time.at(auth.credentials.expires_at)
    }

    find_by(provider: auth.provider, uid: auth.uid)&.tap { |u| u.update!(token_attrs) } ||
      find_by(email: auth.info.email)&.tap { |u|
        u.update!(provider: auth.provider, uid: auth.uid, **token_attrs)
      } ||
      create!(provider: auth.provider, uid: auth.uid, email: auth.info.email,
              password: Devise.friendly_token[0, 20], **token_attrs)
  end

  private

  def add_profile
    language = Profile.languages.key?(Current.locale.to_s) ? Current.locale.to_s : "en"
    create_profile(nickname: UniqueNicknameGenerator.generate(email.split("@").first), language: language)
  end
end
