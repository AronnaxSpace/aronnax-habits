OmniAuth.config.test_mode = true

module OmniAuthHelpers
  def aronnax_auth_hash(overrides = {})
    OmniAuth::AuthHash.new(
      {
        provider: "aronnax",
        uid: "aronnax-uid-123",
        info: { email: "sso-user@example.com" },
        credentials: {
          token: "access-token",
          refresh_token: "refresh-token",
          expires_at: 1.hour.from_now.to_i
        }
      }.deep_merge(overrides)
    )
  end

  def mock_aronnax_auth(overrides = {})
    OmniAuth.config.mock_auth[:aronnax] = aronnax_auth_hash(overrides)
  end

  # Drives the full request -> callback flow in a request spec. The warmup GET
  # establishes a session first: under omniauth-rails_csrf_protection the very
  # first request-phase POST in a session passthru-404s otherwise.
  def authenticate_with_aronnax
    get new_user_session_path
    post "/users/auth/aronnax"
    follow_redirect!
  end
end

RSpec.configure do |config|
  config.include OmniAuthHelpers

  config.after do
    OmniAuth.config.mock_auth[:aronnax] = nil
  end
end
