class User < ApplicationRecord
  # :database_authenticatable is kept only to preserve Devise's sessions
  # routes/controller (new_user_session, etc.) which Devise::FailureApp
  # hardcodes as its redirect target for every unauthenticated request.
  # No password is ever set, so it can never actually authenticate anyone —
  # Aronnax SSO (:omniauthable) is the only working sign-in path.
  devise :database_authenticatable,
         :omniauthable, omniauth_providers: [ :aronnax ]

  # associations
  has_one :profile, dependent: :destroy
  has_many :habits, dependent: :destroy

  # validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  # callbacks
  after_create :add_profile

  def self.from_omniauth(auth)
    token_attrs = {
      aronnax_access_token: auth.credentials.token,
      aronnax_refresh_token: auth.credentials.refresh_token,
      aronnax_expires_at: auth.credentials.expires_at && Time.at(auth.credentials.expires_at)
    }

    # NOTE: the email branch links an SSO login to a pre-existing local account.
    # This is only safe while the Aronnax provider guarantees verified emails
    # (Devise :confirmable on aronnax-core). Without that, it is an
    # account-takeover vector.
    find_by(provider: auth.provider, uid: auth.uid)&.tap { |u| u.update!(token_attrs) } ||
      find_by(email: auth.info.email)&.tap { |u|
        u.update!(provider: auth.provider, uid: auth.uid, **token_attrs)
      } ||
      create!(provider: auth.provider, uid: auth.uid, email: auth.info.email, **token_attrs)
  end

  # Memoized OAuth2 client for calling Aronnax APIs on a user's behalf.
  def self.aronnax_oauth_client
    @aronnax_oauth_client ||= OAuth2::Client.new(
      Rails.application.credentials.dig(:aronnax, :app_id),
      Rails.application.credentials.dig(:aronnax, :app_secret),
      site: Rails.application.credentials.dig(:aronnax, :site)
    )
  end

  # Returns a usable Aronnax access token, refreshing and persisting it when
  # expired. Raises TokenExpiredError if the token is expired and no refresh
  # token is available (e.g. sessions created before refresh tokens were enabled).
  # Scaffolding for future Aronnax API calls — no caller yet.
  def aronnax
    token = aronnax_access_token_raw
    return token unless token.expired?
    raise TokenExpiredError, "Aronnax token expired and no refresh token available" if aronnax_refresh_token.blank?

    token = token.refresh!
    update!(
      aronnax_access_token: token.token,
      aronnax_refresh_token: token.refresh_token,
      aronnax_expires_at: token.expires_at && Time.at(token.expires_at)
    )
    token
  end

  TokenExpiredError = Class.new(StandardError)

  private

  def aronnax_access_token_raw
    OAuth2::AccessToken.new(
      self.class.aronnax_oauth_client,
      aronnax_access_token,
      refresh_token: aronnax_refresh_token,
      expires_at: aronnax_expires_at&.to_i
    )
  end

  def add_profile
    language = Profile.languages.key?(Current.locale.to_s) ? Current.locale.to_s : "en"
    create_profile(nickname: UniqueNicknameGenerator.generate(email.split("@").first), language: language)
  end
end
