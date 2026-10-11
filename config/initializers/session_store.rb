# Keep users signed in across browser restarts. Without expire_after the
# session cookie is dropped when the browser closes, and since sign-in is
# Aronnax SSO only (no Devise :rememberable), nothing else would restore it.
# The expiry slides: it is renewed on each request.
Rails.application.config.session_store :cookie_store,
  key: "_aronnax_habits_session", # Rails' default key, so existing sessions survive the deploy
  expire_after: 2.weeks
