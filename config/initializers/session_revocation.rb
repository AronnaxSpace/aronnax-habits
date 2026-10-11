# Signing out rotates the user's session salt, which revokes every session
# cookie issued for them (other browsers and copied cookies included).
# See User#authenticatable_salt.
Warden::Manager.before_logout do |user, _warden, _options|
  # persisted? skips a user who was just destroyed (account deletion).
  user.rotate_session_salt! if user.respond_to?(:rotate_session_salt!) && user.persisted?
end
