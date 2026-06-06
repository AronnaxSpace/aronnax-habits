class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  around_action :set_locale

  private

  def set_locale(&action)
    locale = if user_signed_in?
      current_user.profile.language.to_sym
    else
      cookies[:locale]&.to_sym || I18n.default_locale
    end
    locale = I18n.default_locale unless I18n.available_locales.include?(locale)
    I18n.with_locale(locale, &action)
  end
end
